const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: [
      'message',
      'friend_request',
      'friend_request_accepted',
      'emotion_shared',
      'emotion_reaction',
      'system',
      'achievement'
    ],
    required: true
  },
  title: {
    type: String,
    required: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  message: {
    type: String,
    required: true,
    maxlength: [500, 'Message cannot exceed 500 characters']
  },
  data: {
    // Flexible field to store type-specific data
    chatId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Chat'
    },
    messageId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Message'
    },
    emotionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Emotion'
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    // Additional custom data
    customData: mongoose.Schema.Types.Mixed
  },
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: {
    type: Date
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium'
  },
  category: {
    type: String,
    enum: ['social', 'system', 'security', 'feature'],
    default: 'social'
  },
  actionUrl: {
    type: String // Deep link or route for the notification action
  },
  expiresAt: {
    type: Date,
    default: function() {
      // Auto-delete after 30 days
      return new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    }
  },
  isDeleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Index for better performance
notificationSchema.index({ recipient: 1, createdAt: -1 });
notificationSchema.index({ recipient: 1, isRead: 1 });
notificationSchema.index({ type: 1 });
notificationSchema.index({ priority: 1 });
notificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Virtual for time ago
notificationSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);

  if (minutes < 1) return 'Just now';
  if (minutes < 60) return `${minutes} min ago`;
  if (hours < 24) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
  return `${days} day${days > 1 ? 's' : ''} ago`;
});

// Method to mark as read
notificationSchema.methods.markAsRead = function() {
  this.isRead = true;
  this.readAt = new Date();
};

// Method to check if expired
notificationSchema.methods.isExpired = function() {
  return this.expiresAt && new Date() > this.expiresAt;
};

// Static method to create notification
notificationSchema.statics.createNotification = async function(data) {
  const notification = new this(data);
  await notification.save();
  
  // Populate sender information
  await notification.populate('sender', 'name email avatar');
  
  return notification;
};

// Static method to get notifications for user
notificationSchema.statics.getNotificationsForUser = function(userId, page = 1, limit = 20, unreadOnly = false) {
  const skip = (page - 1) * limit;
  const query = {
    recipient: userId,
    isDeleted: false
  };
  
  if (unreadOnly) {
    query.isRead = false;
  }
  
  return this.find(query)
    .populate('sender', 'name email avatar')
    .populate('data.chatId', 'name type')
    .populate('data.emotionId', 'detectedEmotion ghibliArt')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);
};

// Static method to get unread count for user
notificationSchema.statics.getUnreadCountForUser = function(userId) {
  return this.countDocuments({
    recipient: userId,
    isRead: false,
    isDeleted: false
  });
};

// Static method to mark all as read for user
notificationSchema.statics.markAllAsReadForUser = function(userId) {
  return this.updateMany(
    {
      recipient: userId,
      isRead: false,
      isDeleted: false
    },
    {
      $set: {
        isRead: true,
        readAt: new Date()
      }
    }
  );
};

// Static method to create friend request notification
notificationSchema.statics.createFriendRequestNotification = function(senderId, recipientId) {
  return this.createNotification({
    recipient: recipientId,
    sender: senderId,
    type: 'friend_request',
    title: 'New Friend Request',
    message: 'wants to be your friend',
    data: {
      userId: senderId
    },
    priority: 'medium',
    category: 'social',
    actionUrl: '/friends/requests'
  });
};

// Static method to create message notification
notificationSchema.statics.createMessageNotification = function(senderId, recipientId, chatId, messagePreview) {
  return this.createNotification({
    recipient: recipientId,
    sender: senderId,
    type: 'message',
    title: 'New Message',
    message: messagePreview || 'sent you a message',
    data: {
      chatId: chatId
    },
    priority: 'high',
    category: 'social',
    actionUrl: `/chat/${chatId}`
  });
};

// Static method to create emotion shared notification
notificationSchema.statics.createEmotionSharedNotification = function(senderId, recipientId, emotionId) {
  return this.createNotification({
    recipient: recipientId,
    sender: senderId,
    type: 'emotion_shared',
    title: 'Emotion Shared',
    message: 'shared an emotion with you',
    data: {
      emotionId: emotionId
    },
    priority: 'medium',
    category: 'social',
    actionUrl: `/emotions/${emotionId}`
  });
};

// Static method to create system notification
notificationSchema.statics.createSystemNotification = function(recipientId, title, message, data = {}) {
  return this.createNotification({
    recipient: recipientId,
    sender: recipientId, // System notifications use the same user as sender
    type: 'system',
    title: title,
    message: message,
    data: {
      customData: data
    },
    priority: 'low',
    category: 'system'
  });
};

// Static method to clean expired notifications
notificationSchema.statics.cleanExpiredNotifications = function() {
  return this.deleteMany({
    expiresAt: { $lt: new Date() }
  });
};

module.exports = mongoose.model('Notification', notificationSchema);