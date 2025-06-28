const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
    minlength: [2, 'Name must be at least 2 characters'],
    maxlength: [50, 'Name cannot exceed 50 characters']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [
      /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
      'Please provide a valid email'
    ]
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters'],
    select: false // Don't include password in queries by default
  },
  avatar: {
    type: String,
    default: null
  },
  bio: {
    type: String,
    maxlength: [200, 'Bio cannot exceed 200 characters'],
    default: ''
  },
  isOnline: {
    type: Boolean,
    default: false
  },
  lastSeen: {
    type: Date,
    default: Date.now
  },
  friends: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    addedAt: {
      type: Date,
      default: Date.now
    }
  }],
  friendRequests: {
    sent: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      sentAt: {
        type: Date,
        default: Date.now
      }
    }],
    received: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      receivedAt: {
        type: Date,
        default: Date.now
      }
    }]
  },
  emotionStats: {
    totalEmotions: {
      type: Number,
      default: 0
    },
    emotionCounts: {
      happy: { type: Number, default: 0 },
      sad: { type: Number, default: 0 },
      angry: { type: Number, default: 0 },
      surprised: { type: Number, default: 0 },
      neutral: { type: Number, default: 0 },
      excited: { type: Number, default: 0 },
      confused: { type: Number, default: 0 },
      disgusted: { type: Number, default: 0 }
    }
  },
  settings: {
    notifications: {
      messages: { type: Boolean, default: true },
      friendRequests: { type: Boolean, default: true },
      emotionShares: { type: Boolean, default: true }
    },
    privacy: {
      showOnlineStatus: { type: Boolean, default: true },
      allowEmotionSharing: { type: Boolean, default: true }
    },
    preferences: {
      language: { type: String, default: 'en' },
      theme: { type: String, default: 'system' }
    }
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  verificationToken: String,
  passwordResetToken: String,
  passwordResetExpires: Date,
  refreshTokens: [{
    token: String,
    createdAt: {
      type: Date,
      default: Date.now,
      expires: 604800 // 7 days
    }
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for mutual friends count
userSchema.virtual('mutualFriendsCount').get(function() {
  return this.friends ? this.friends.length : 0;
});

// Index for better performance
userSchema.index({ email: 1 });
userSchema.index({ name: 'text', email: 'text' });
userSchema.index({ isOnline: 1 });

// Pre-save middleware to hash password
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to get public profile
userSchema.methods.getPublicProfile = function() {
  const userObject = this.toObject();
  delete userObject.password;
  delete userObject.refreshTokens;
  delete userObject.verificationToken;
  delete userObject.passwordResetToken;
  delete userObject.passwordResetExpires;
  return userObject;
};

// Method to check if users are friends
userSchema.methods.isFriendWith = function(userId) {
  return this.friends.some(friend => friend.user.toString() === userId.toString());
};

// Method to add friend
userSchema.methods.addFriend = function(userId) {
  if (!this.isFriendWith(userId)) {
    this.friends.push({ user: userId });
  }
};

// Method to remove friend
userSchema.methods.removeFriend = function(userId) {
  this.friends = this.friends.filter(friend => friend.user.toString() !== userId.toString());
};

// Method to update emotion stats
userSchema.methods.updateEmotionStats = function(emotion) {
  this.emotionStats.totalEmotions += 1;
  if (this.emotionStats.emotionCounts[emotion.toLowerCase()]) {
    this.emotionStats.emotionCounts[emotion.toLowerCase()] += 1;
  }
};

// Static method to find users by search query
userSchema.statics.findBySearchQuery = function(query, currentUserId) {
  return this.find({
    _id: { $ne: currentUserId },
    $or: [
      { name: { $regex: query, $options: 'i' } },
      { email: { $regex: query, $options: 'i' } }
    ]
  }).select('-password -refreshTokens -verificationToken -passwordResetToken');
};

module.exports = mongoose.model('User', userSchema);