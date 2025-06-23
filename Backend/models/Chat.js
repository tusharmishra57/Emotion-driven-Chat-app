const mongoose = require('mongoose');

const chatSchema = new mongoose.Schema({
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }],
  type: {
    type: String,
    enum: ['private', 'group'],
    default: 'private'
  },
  name: {
    type: String,
    trim: true,
    maxlength: [100, 'Chat name cannot exceed 100 characters']
  },
  description: {
    type: String,
    maxlength: [500, 'Chat description cannot exceed 500 characters']
  },
  avatar: {
    type: String,
    default: null
  },
  lastMessage: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message'
  },
  lastActivity: {
    type: Date,
    default: Date.now
  },
  isActive: {
    type: Boolean,
    default: true
  },
  settings: {
    allowEmotions: {
      type: Boolean,
      default: true
    },
    muteNotifications: {
      type: Boolean,
      default: false
    }
  },
  // For group chats
  admin: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  // Typing indicators
  typingUsers: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    timestamp: {
      type: Date,
      default: Date.now
    }
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for message count
chatSchema.virtual('messageCount', {
  ref: 'Message',
  localField: '_id',
  foreignField: 'chat',
  count: true
});

// Index for better performance
chatSchema.index({ participants: 1 });
chatSchema.index({ lastActivity: -1 });
chatSchema.index({ type: 1 });

// Pre-save middleware
chatSchema.pre('save', function(next) {
  this.lastActivity = new Date();
  next();
});

// Method to check if user is participant
chatSchema.methods.isParticipant = function(userId) {
  return this.participants.some(participant => participant.toString() === userId.toString());
};

// Method to add participant (for group chats)
chatSchema.methods.addParticipant = function(userId) {
  if (!this.isParticipant(userId)) {
    this.participants.push(userId);
  }
};

// Method to remove participant (for group chats)
chatSchema.methods.removeParticipant = function(userId) {
  this.participants = this.participants.filter(participant => participant.toString() !== userId.toString());
};

// Method to get other participant (for private chats)
chatSchema.methods.getOtherParticipant = function(currentUserId) {
  if (this.type === 'private') {
    return this.participants.find(participant => participant.toString() !== currentUserId.toString());
  }
  return null;
};

// Method to update typing status
chatSchema.methods.updateTypingStatus = function(userId, isTyping) {
  if (isTyping) {
    // Add or update typing status
    const existingTyping = this.typingUsers.find(typing => typing.user.toString() === userId.toString());
    if (existingTyping) {
      existingTyping.timestamp = new Date();
    } else {
      this.typingUsers.push({ user: userId, timestamp: new Date() });
    }
  } else {
    // Remove typing status
    this.typingUsers = this.typingUsers.filter(typing => typing.user.toString() !== userId.toString());
  }
};

// Method to clean old typing indicators
chatSchema.methods.cleanOldTypingIndicators = function() {
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
  this.typingUsers = this.typingUsers.filter(typing => typing.timestamp > fiveMinutesAgo);
};

// Static method to find chats for user
chatSchema.statics.findChatsForUser = function(userId) {
  return this.find({
    participants: userId,
    isActive: true
  })
  .populate('participants', 'name email avatar isOnline lastSeen')
  .populate('lastMessage')
  .sort({ lastActivity: -1 });
};

// Static method to find or create private chat
chatSchema.statics.findOrCreatePrivateChat = async function(user1Id, user2Id) {
  let chat = await this.findOne({
    type: 'private',
    participants: { $all: [user1Id, user2Id] }
  }).populate('participants', 'name email avatar isOnline lastSeen');

  if (!chat) {
    chat = await this.create({
      type: 'private',
      participants: [user1Id, user2Id]
    });
    
    chat = await this.findById(chat._id)
      .populate('participants', 'name email avatar isOnline lastSeen');
  }

  return chat;
};

module.exports = mongoose.model('Chat', chatSchema);