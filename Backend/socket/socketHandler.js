const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Chat = require('../models/Chat');
const Message = require('../models/Message');
const Notification = require('../models/Notification');

// Store active connections
const activeUsers = new Map();
const userSockets = new Map();

const socketAuth = async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    
    if (!token) {
      return next(new Error('Authentication error: No token provided'));
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password -refreshTokens');
    
    if (!user) {
      return next(new Error('Authentication error: User not found'));
    }

    socket.userId = user._id.toString();
    socket.user = user;
    next();
  } catch (error) {
    next(new Error('Authentication error: Invalid token'));
  }
};

const socketHandler = (io) => {
  // Authentication middleware
  io.use(socketAuth);

  io.on('connection', async (socket) => {
    const userId = socket.userId;
    const user = socket.user;

    console.log(`User ${user.name} connected with socket ${socket.id}`);

    // Store user connection
    activeUsers.set(userId, {
      socketId: socket.id,
      user: user,
      lastSeen: new Date()
    });
    userSockets.set(socket.id, userId);

    // Update user online status
    await User.findByIdAndUpdate(userId, {
      isOnline: true,
      lastSeen: new Date()
    });

    // Join user to their personal room
    socket.join(`user_${userId}`);

    // Join user to their chat rooms
    try {
      const userChats = await Chat.find({
        participants: userId,
        isActive: true
      });

      userChats.forEach(chat => {
        socket.join(`chat_${chat._id}`);
      });
    } catch (error) {
      console.error('Error joining chat rooms:', error);
    }

    // Emit user online status to friends
    try {
      const userWithFriends = await User.findById(userId).populate('friends.user', '_id');
      const friendIds = userWithFriends.friends.map(friend => friend.user._id.toString());
      
      friendIds.forEach(friendId => {
        socket.to(`user_${friendId}`).emit('user_online', {
          userId: userId,
          user: {
            _id: userId,
            name: user.name,
            avatar: user.avatar
          }
        });
      });
    } catch (error) {
      console.error('Error notifying friends of online status:', error);
    }

    // Handle joining a chat
    socket.on('join_chat', async (data) => {
      try {
        const { chatId } = data;
        
        const chat = await Chat.findById(chatId);
        if (!chat || !chat.isParticipant(userId)) {
          socket.emit('error', { message: 'Access denied to chat' });
          return;
        }

        socket.join(`chat_${chatId}`);
        
        // Notify other participants that user joined
        socket.to(`chat_${chatId}`).emit('user_joined_chat', {
          chatId,
          user: {
            _id: userId,
            name: user.name,
            avatar: user.avatar
          }
        });

        socket.emit('joined_chat', { chatId });
      } catch (error) {
        console.error('Error joining chat:', error);
        socket.emit('error', { message: 'Failed to join chat' });
      }
    });

    // Handle leaving a chat
    socket.on('leave_chat', (data) => {
      const { chatId } = data;
      socket.leave(`chat_${chatId}`);
      
      socket.to(`chat_${chatId}`).emit('user_left_chat', {
        chatId,
        user: {
          _id: userId,
          name: user.name,
          avatar: user.avatar
        }
      });
    });

    // Handle sending messages
    socket.on('send_message', async (data) => {
      try {
        const { chatId, content, type, replyTo } = data;

        // Verify chat access
        const chat = await Chat.findById(chatId);
        if (!chat || !chat.isParticipant(userId)) {
          socket.emit('error', { message: 'Access denied to chat' });
          return;
        }

        // Create message
        const message = new Message({
          chat: chatId,
          sender: userId,
          content,
          type,
          replyTo
        });

        await message.save();

        // Update chat
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

        // Emit to chat participants
        io.to(`chat_${chatId}`).emit('new_message', {
          message,
          chatId
        });

        // Create notifications for offline users
        const otherParticipants = chat.participants.filter(
          p => p.toString() !== userId
        );

        for (const participantId of otherParticipants) {
          const isOnline = activeUsers.has(participantId.toString());
          
          if (!isOnline) {
            const messagePreview = type === 'text' 
              ? content.text?.substring(0, 50) + (content.text?.length > 50 ? '...' : '')
              : type === 'emotion' 
              ? 'sent an emotion'
              : `sent ${type}`;

            await Notification.createMessageNotification(
              userId,
              participantId,
              chatId,
              messagePreview
            );
          }
        }

      } catch (error) {
        console.error('Error sending message:', error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // Handle typing indicators
    socket.on('typing_start', async (data) => {
      try {
        const { chatId } = data;
        
        const chat = await Chat.findById(chatId);
        if (!chat || !chat.isParticipant(userId)) {
          return;
        }

        socket.to(`chat_${chatId}`).emit('user_typing', {
          chatId,
          user: {
            _id: userId,
            name: user.name,
            avatar: user.avatar
          },
          isTyping: true
        });

        // Update chat typing status
        chat.updateTypingStatus(userId, true);
        await chat.save();
      } catch (error) {
        console.error('Error handling typing start:', error);
      }
    });

    socket.on('typing_stop', async (data) => {
      try {
        const { chatId } = data;
        
        const chat = await Chat.findById(chatId);
        if (!chat || !chat.isParticipant(userId)) {
          return;
        }

        socket.to(`chat_${chatId}`).emit('user_typing', {
          chatId,
          user: {
            _id: userId,
            name: user.name,
            avatar: user.avatar
          },
          isTyping: false
        });

        // Update chat typing status
        chat.updateTypingStatus(userId, false);
        await chat.save();
      } catch (error) {
        console.error('Error handling typing stop:', error);
      }
    });

    // Handle message reactions
    socket.on('add_reaction', async (data) => {
      try {
        const { messageId, emoji } = data;

        const message = await Message.findById(messageId);
        if (!message) {
          socket.emit('error', { message: 'Message not found' });
          return;
        }

        message.addReaction(userId, emoji);
        await message.save();

        // Emit to chat participants
        io.to(`chat_${message.chat}`).emit('message_reaction', {
          messageId,
          reactions: message.reactions,
          reactionCounts: message.reactionCounts
        });

      } catch (error) {
        console.error('Error adding reaction:', error);
        socket.emit('error', { message: 'Failed to add reaction' });
      }
    });

    // Handle message read status
    socket.on('mark_messages_read', async (data) => {
      try {
        const { chatId } = data;

        await Message.markAllAsReadInChat(chatId, userId);

        // Notify other participants
        socket.to(`chat_${chatId}`).emit('messages_read', {
          chatId,
          userId,
          readAt: new Date()
        });

      } catch (error) {
        console.error('Error marking messages as read:', error);
      }
    });

    // Handle friend requests
    socket.on('send_friend_request', async (data) => {
      try {
        const { targetUserId } = data;

        // Emit to target user if online
        socket.to(`user_${targetUserId}`).emit('friend_request_received', {
          from: {
            _id: userId,
            name: user.name,
            avatar: user.avatar
          }
        });

      } catch (error) {
        console.error('Error sending friend request notification:', error);
      }
    });

    // Handle emotion sharing
    socket.on('share_emotion', async (data) => {
      try {
        const { emotionId, recipients } = data;

        // Emit to recipients if online
        recipients.forEach(recipientId => {
          socket.to(`user_${recipientId}`).emit('emotion_shared', {
            emotionId,
            from: {
              _id: userId,
              name: user.name,
              avatar: user.avatar
            }
          });
        });

      } catch (error) {
        console.error('Error sharing emotion notification:', error);
      }
    });

    // Handle notifications
    socket.on('mark_notification_read', async (data) => {
      try {
        const { notificationId } = data;

        const notification = await Notification.findById(notificationId);
        if (notification && notification.recipient.toString() === userId) {
          notification.markAsRead();
          await notification.save();

          socket.emit('notification_updated', {
            notificationId,
            isRead: true,
            readAt: notification.readAt
          });
        }

      } catch (error) {
        console.error('Error marking notification as read:', error);
      }
    });

    // Handle disconnect
    socket.on('disconnect', async () => {
      console.log(`User ${user.name} disconnected`);

      // Remove from active users
      activeUsers.delete(userId);
      userSockets.delete(socket.id);

      // Update user offline status
      await User.findByIdAndUpdate(userId, {
        isOnline: false,
        lastSeen: new Date()
      });

      // Notify friends of offline status
      try {
        const userWithFriends = await User.findById(userId).populate('friends.user', '_id');
        const friendIds = userWithFriends.friends.map(friend => friend.user._id.toString());
        
        friendIds.forEach(friendId => {
          socket.to(`user_${friendId}`).emit('user_offline', {
            userId: userId,
            lastSeen: new Date()
          });
        });
      } catch (error) {
        console.error('Error notifying friends of offline status:', error);
      }

      // Stop typing in all chats
      try {
        const userChats = await Chat.find({
          participants: userId,
          isActive: true
        });

        for (const chat of userChats) {
          chat.updateTypingStatus(userId, false);
          await chat.save();

          socket.to(`chat_${chat._id}`).emit('user_typing', {
            chatId: chat._id,
            user: {
              _id: userId,
              name: user.name,
              avatar: user.avatar
            },
            isTyping: false
          });
        }
      } catch (error) {
        console.error('Error cleaning up typing status:', error);
      }
    });

    // Send initial data
    socket.emit('connected', {
      userId,
      user: user.getPublicProfile(),
      timestamp: new Date()
    });
  });

  // Helper function to emit to user if online
  const emitToUser = (userId, event, data) => {
    const userConnection = activeUsers.get(userId);
    if (userConnection) {
      io.to(`user_${userId}`).emit(event, data);
      return true;
    }
    return false;
  };

  // Helper function to emit to chat
  const emitToChat = (chatId, event, data) => {
    io.to(`chat_${chatId}`).emit(event, data);
  };

  // Export helper functions for use in routes
  io.emitToUser = emitToUser;
  io.emitToChat = emitToChat;
  io.getActiveUsers = () => Array.from(activeUsers.keys());
  io.isUserOnline = (userId) => activeUsers.has(userId);

  return io;
};

module.exports = socketHandler;
