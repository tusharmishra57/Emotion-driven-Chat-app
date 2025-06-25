const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  chat: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chat',
    required: true
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    text: {
      type: String,
      maxlength: [1000, 'Message cannot exceed 1000 characters']
    },
    emotion: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Emotion'
    },
    attachment: {
      type: {
        type: String,
        enum: ['image', 'video', 'audio', 'file']
      },
      url: String,
      filename: String,
      size: Number,
      mimeType: String
    }
  },
  type: {
    type: String,
    enum: ['text', 'emotion', 'image', 'video', 'audio', 'file', 'system'],
    required: true,
    default: 'text'
  },
  status: {
    type: String,
    enum: ['sent', 'delivered', 'read'],
    default: 'sent'
  },
  readBy: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    readAt: {
      type: Date,
      default: Date.now
    }
  }],
  editedAt: {
    type: Date
  },
  isEdited: {
    type: Boolean,
    default: false
  },
  replyTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message'
  },
  reactions: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    emoji: {
      type: String,
      required: true
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  isDeleted: {
    type: Boolean,
    default: false
  },
  deletedAt: {
    type: Date
  },
  deletedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for reaction counts
messageSchema.virtual('reactionCounts').get(function() {
  const counts = {};
  this.reactions.forEach(reaction => {
    counts[reaction.emoji] = (counts[reaction.emoji] || 0) + 1;
  });
  return counts;
});

// Index for better performance
messageSchema.index({ chat: 1, createdAt: -1 });
messageSchema.index({ sender: 1 });
messageSchema.index({ type: 1 });
messageSchema.index({ status: 1 });

// Pre-save middleware
messageSchema.pre('save', function(next) {
  if (this.isModified('content.text') && !this.isNew) {
    this.isEdited = true;
    this.editedAt = new Date();
  }
  next();
});

// Method to mark as read by user
messageSchema.methods.markAsReadBy = function(userId) {
  const existingRead = this.readBy.find(read => read.user.toString() === userId.toString());
  if (!existingRead) {
    this.readBy.push({ user: userId, readAt: new Date() });
    this.status = 'read';
  }
};

// Method to add reaction
messageSchema.methods.addReaction = function(userId, emoji) {
  // Remove existing reaction from this user
  this.reactions = this.reactions.filter(reaction => reaction.user.toString() !== userId.toString());
  
  // Add new reaction
  this.reactions.push({
    user: userId,
    emoji: emoji,
    createdAt: new Date()
  });
};

// Method to remove reaction
messageSchema.methods.removeReaction = function(userId, emoji) {
  this.reactions = this.reactions.filter(reaction => 
    !(reaction.user.toString() === userId.toString() && reaction.emoji === emoji)
  );
};

// Method to soft delete
messageSchema.methods.softDelete = function(userId) {
  this.isDeleted = true;
  this.deletedAt = new Date();
  this.deletedBy = userId;
};

// Method to check if user can edit
messageSchema.methods.canEdit = function(userId) {
  return this.sender.toString() === userId.toString() && 
         !this.isDeleted && 
         (Date.now() - this.createdAt.getTime()) < 15 * 60 * 1000; // 15 minutes
};

// Method to check if user can delete
messageSchema.methods.canDelete = function(userId) {
  return this.sender.toString() === userId.toString() && !this.isDeleted;
};

// Static method to get messages for chat
messageSchema.statics.getMessagesForChat = function(chatId, page = 1, limit = 50) {
  const skip = (page - 1) * limit;
  
  return this.find({
    chat: chatId,
    isDeleted: false
  })
  .populate('sender', 'name email avatar')
  .populate('content.emotion')
  .populate('replyTo')
  .sort({ createdAt: -1 })
  .skip(skip)
  .limit(limit);
};

// Static method to get unread message count for user
messageSchema.statics.getUnreadCountForUser = function(userId) {
  return this.aggregate([
    {
      $lookup: {
        from: 'chats',
        localField: 'chat',
        foreignField: '_id',
        as: 'chatInfo'
      }
    },
    {
      $match: {
        'chatInfo.participants': userId,
        sender: { $ne: userId },
        isDeleted: false,
        'readBy.user': { $ne: userId }
      }
    },
    {
      $group: {
        _id: '$chat',
        unreadCount: { $sum: 1 }
      }
    }
  ]);
};

// Static method to mark all messages as read in a chat
messageSchema.statics.markAllAsReadInChat = function(chatId, userId) {
  return this.updateMany(
    {
      chat: chatId,
      sender: { $ne: userId },
      'readBy.user': { $ne: userId },
      isDeleted: false
    },
    {
      $push: {
        readBy: {
          user: userId,
          readAt: new Date()
        }
      },
      $set: {
        status: 'read'
      }
    }
  );
};

module.exports = mongoose.model('Message', messageSchema);