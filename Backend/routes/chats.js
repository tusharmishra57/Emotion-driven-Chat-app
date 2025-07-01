const express = require('express');
const Chat = require('../models/Chat');
const Message = require('../models/Message');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { auth } = require('../middleware/auth');
const { validateCreateChat, validateSendMessage, validateReaction } = require('../middleware/validation');

const router = express.Router();

// @route   GET /api/chats
// @desc    Get user's chats
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    
    const chats = await Chat.findChatsForUser(req.user._id)
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit));

    // Get unread message counts for each chat
    const chatIds = chats.map(chat => chat._id);
    const unreadCounts = await Message.getUnreadCountForUser(req.user._id);
    const unreadMap = {};
    unreadCounts.forEach(item => {
      unreadMap[item._id.toString()] = item.unreadCount;
    });

    const chatsWithUnread = chats.map(chat => {
      const chatObj = chat.toObject();
      chatObj.unreadCount = unreadMap[chat._id.toString()] || 0;
      
      // For private chats, get the other participant's info
      if (chat.type === 'private') {
        const otherParticipant = chat.participants.find(
          p => p._id.toString() !== req.user._id.toString()
        );
        chatObj.name = otherParticipant?.name;
        chatObj.avatar = otherParticipant?.avatar;
        chatObj.isOnline = otherParticipant?.isOnline;
        chatObj.lastSeen = otherParticipant?.lastSeen;
      }
      
      return chatObj;
    });

    res.json({
      success: true,
      data: {
        chats: chatsWithUnread,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: chats.length
        }
      }
    });

  } catch (error) {
    console.error('Get chats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching chats'
    });
  }
});

// @route   POST /api/chats
// @desc    Create a new chat
// @access  Private
router.post('/', auth, validateCreateChat, async (req, res) => {
  try {
    const { participants, type = 'private', name, description } = req.body;
    
    // Add current user to participants if not already included
    if (!participants.includes(req.user._id.toString())) {
      participants.push(req.user._id);
    }

    // For private chats, ensure only 2 participants
    if (type === 'private' && participants.length !== 2) {
      return res.status(400).json({
        success: false,
        message: 'Private chats must have exactly 2 participants'
      });
    }

    // Check if private chat already exists
    if (type === 'private') {
      const existingChat = await Chat.findOrCreatePrivateChat(
        req.user._id,
        participants.find(p => p !== req.user._id.toString())
      );
      
      return res.json({
        success: true,
        message: 'Chat retrieved successfully',
        data: { chat: existingChat }
      });
    }

    // Verify all participants exist
    const users = await User.find({ _id: { $in: participants } });
    if (users.length !== participants.length) {
      return res.status(400).json({
        success: false,
        message: 'One or more participants not found'
      });
    }

    // Create group chat
    const chat = new Chat({
      participants,
      type,
      name,
      description,
      admin: req.user._id
    });

    await chat.save();
    
    const populatedChat = await Chat.findById(chat._id)
      .populate('participants', 'name email avatar isOnline lastSeen');

    res.status(201).json({
      success: true,
      message: 'Chat created successfully',
      data: { chat: populatedChat }
    });

  } catch (error) {
    console.error('Create chat error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating chat'
    });
  }
});

// @route   GET /api/chats/:id
// @desc    Get chat details
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.id)
      .populate('participants', 'name email avatar isOnline lastSeen')
      .populate('lastMessage');

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    // Check if user is participant
    if (!chat.isParticipant(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You are not a participant in this chat.'
      });
    }

    // Clean old typing indicators
    chat.cleanOldTypingIndicators();
    await chat.save();

    const chatObj = chat.toObject();
    
    // For private chats, get the other participant's info
    if (chat.type === 'private') {
      const otherParticipant = chat.participants.find(
        p => p._id.toString() !== req.user._id.toString()
      );
      chatObj.name = otherParticipant?.name;
      chatObj.avatar = otherParticipant?.avatar;
      chatObj.isOnline = otherParticipant?.isOnline;
      chatObj.lastSeen = otherParticipant?.lastSeen;
    }

    res.json({
      success: true,
      data: { chat: chatObj }
    });

  } catch (error) {
    console.error('Get chat error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching chat'
    });
  }
});

// @route   GET /api/chats/:id/messages
// @desc    Get chat messages
// @access  Private
router.get('/:id/messages', auth, async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const chatId = req.params.id;

    // Verify chat exists and user is participant
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    if (!chat.isParticipant(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You are not a participant in this chat.'
      });
    }

    const messages = await Message.getMessagesForChat(chatId, parseInt(page), parseInt(limit));

    // Mark messages as read
    await Message.markAllAsReadInChat(chatId, req.user._id);

    res.json({
      success: true,
      data: {
        messages: messages.reverse(), // Reverse to show oldest first
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: messages.length
        }
      }
    });

  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching messages'
    });
  }
});

// @route   POST /api/chats/:id/messages
// @desc    Send a message
// @access  Private
router.post('/:id/messages', auth, validateSendMessage, async (req, res) => {
  try {
    const { content, type, replyTo } = req.body;
    const chatId = req.params.id;

    // Verify chat exists and user is participant
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    if (!chat.isParticipant(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You are not a participant in this chat.'
      });
    }

    // Validate content based on type
    if (type === 'text' && (!content.text || content.text.trim().length === 0)) {
      return res.status(400).json({
        success: false,
        message: 'Text content is required for text messages'
      });
    }

    if (type === 'emotion' && !content.emotion) {
      return res.status(400).json({
        success: false,
        message: 'Emotion ID is required for emotion messages'
      });
    }

    // Create message
    const message = new Message({
      chat: chatId,
      sender: req.user._id,
      content,
      type,
      replyTo
    });

    await message.save();

    // Update chat's last message and activity
    chat.lastMessage = message._id;
    chat.lastActivity = new Date();
    await chat.save();

    // Populate message data
    await message.populate('sender', 'name email avatar');
    if (message.content.emotion) {
      await message.populate('content.emotion');
    }
    if (message.replyTo) {
      await message.populate('replyTo');
    }

    // Create notifications for other participants
    const otherParticipants = chat.participants.filter(
      p => p.toString() !== req.user._id.toString()
    );

    const notificationPromises = otherParticipants.map(participantId => {
      const messagePreview = type === 'text' 
        ? content.text.substring(0, 50) + (content.text.length > 50 ? '...' : '')
        : type === 'emotion' 
        ? 'sent an emotion'
        : `sent ${type}`;

      return Notification.createMessageNotification(
        req.user._id,
        participantId,
        chatId,
        messagePreview
      );
    });

    await Promise.all(notificationPromises);

    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: { message }
    });

  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while sending message'
    });
  }
});

// @route   PUT /api/chats/:chatId/messages/:messageId
// @desc    Edit a message
// @access  Private
router.put('/:chatId/messages/:messageId', auth, async (req, res) => {
  try {
    const { content } = req.body;
    const { chatId, messageId } = req.params;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Check if user can edit this message
    if (!message.canEdit(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'You can only edit your own messages within 15 minutes'
      });
    }

    // Update message content
    if (content.text) {
      message.content.text = content.text;
    }

    await message.save();

    res.json({
      success: true,
      message: 'Message updated successfully',
      data: { message }
    });

  } catch (error) {
    console.error('Edit message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while editing message'
    });
  }
});

// @route   DELETE /api/chats/:chatId/messages/:messageId
// @desc    Delete a message
// @access  Private
router.delete('/:chatId/messages/:messageId', auth, async (req, res) => {
  try {
    const { messageId } = req.params;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Check if user can delete this message
    if (!message.canDelete(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own messages'
      });
    }

    // Soft delete the message
    message.softDelete(req.user._id);
    await message.save();

    res.json({
      success: true,
      message: 'Message deleted successfully'
    });

  } catch (error) {
    console.error('Delete message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting message'
    });
  }
});

// @route   POST /api/chats/:chatId/messages/:messageId/react
// @desc    Add reaction to message
// @access  Private
router.post('/:chatId/messages/:messageId/react', auth, validateReaction, async (req, res) => {
  try {
    const { emoji } = req.body;
    const { messageId } = req.params;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Add reaction
    message.addReaction(req.user._id, emoji);
    await message.save();

    res.json({
      success: true,
      message: 'Reaction added successfully',
      data: {
        reactions: message.reactions,
        reactionCounts: message.reactionCounts
      }
    });

  } catch (error) {
    console.error('Add reaction error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while adding reaction'
    });
  }
});

// @route   DELETE /api/chats/:chatId/messages/:messageId/react
// @desc    Remove reaction from message
// @access  Private
router.delete('/:chatId/messages/:messageId/react', auth, async (req, res) => {
  try {
    const { emoji } = req.body;
    const { messageId } = req.params;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Remove reaction
    message.removeReaction(req.user._id, emoji);
    await message.save();

    res.json({
      success: true,
      message: 'Reaction removed successfully',
      data: {
        reactions: message.reactions,
        reactionCounts: message.reactionCounts
      }
    });

  } catch (error) {
    console.error('Remove reaction error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while removing reaction'
    });
  }
});

// @route   POST /api/chats/:id/typing
// @desc    Update typing status
// @access  Private
router.post('/:id/typing', auth, async (req, res) => {
  try {
    const { isTyping } = req.body;
    const chatId = req.params.id;

    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    if (!chat.isParticipant(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Update typing status
    chat.updateTypingStatus(req.user._id, isTyping);
    await chat.save();

    res.json({
      success: true,
      message: 'Typing status updated'
    });

  } catch (error) {
    console.error('Update typing status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating typing status'
    });
  }
});

module.exports = router;