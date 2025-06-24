const mongoose = require('mongoose');

const emotionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  originalImage: {
    url: {
      type: String,
      required: true
    },
    publicId: String, // For Cloudinary
    filename: String,
    size: Number,
    mimeType: String
  },
  detectedEmotion: {
    primary: {
      type: String,
      required: true,
      enum: ['happy', 'sad', 'angry', 'surprised', 'neutral', 'excited', 'confused', 'disgusted']
    },
    confidence: {
      type: Number,
      required: true,
      min: 0,
      max: 1
    },
    allEmotions: [{
      emotion: {
        type: String,
        enum: ['happy', 'sad', 'angry', 'surprised', 'neutral', 'excited', 'confused', 'disgusted']
      },
      confidence: {
        type: Number,
        min: 0,
        max: 1
      }
    }]
  },
  ghibliArt: {
    url: {
      type: String,
      required: true
    },
    publicId: String, // For Cloudinary
    style: {
      type: String,
      default: 'ghibli'
    },
    prompt: String, // The prompt used to generate the art
    generationTime: Number // Time taken to generate in seconds
  },
  metadata: {
    faceDetected: {
      type: Boolean,
      default: true
    },
    faceCount: {
      type: Number,
      default: 1
    },
    imageQuality: {
      type: String,
      enum: ['low', 'medium', 'high'],
      default: 'medium'
    },
    processingTime: Number, // Total processing time in seconds
    apiVersion: String // Version of the emotion detection API used
  },
  sharing: {
    isShared: {
      type: Boolean,
      default: false
    },
    sharedWith: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      sharedAt: {
        type: Date,
        default: Date.now
      },
      message: String // Optional message when sharing
    }],
    isPublic: {
      type: Boolean,
      default: false
    },
    allowDownload: {
      type: Boolean,
      default: false
    }
  },
  reactions: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    reaction: {
      type: String,
      enum: ['like', 'love', 'laugh', 'wow', 'sad', 'angry']
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  tags: [{
    type: String,
    trim: true,
    lowercase: true
  }],
  isDeleted: {
    type: Boolean,
    default: false
  },
  deletedAt: Date,
  expiresAt: {
    type: Date,
    default: function() {
      // Auto-delete after 30 days if not shared
      return new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for reaction counts
emotionSchema.virtual('reactionCounts').get(function() {
  const counts = {};
  this.reactions.forEach(reaction => {
    counts[reaction.reaction] = (counts[reaction.reaction] || 0) + 1;
  });
  return counts;
});

// Virtual for total shares
emotionSchema.virtual('shareCount').get(function() {
  return this.sharing.sharedWith ? this.sharing.sharedWith.length : 0;
});

// Index for better performance
emotionSchema.index({ user: 1, createdAt: -1 });
emotionSchema.index({ 'detectedEmotion.primary': 1 });
emotionSchema.index({ 'sharing.isPublic': 1 });
emotionSchema.index({ 'sharing.isShared': 1 });
emotionSchema.index({ tags: 1 });
emotionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Pre-save middleware
emotionSchema.pre('save', function(next) {
  // If emotion is shared, remove expiration
  if (this.sharing.isShared && this.expiresAt) {
    this.expiresAt = undefined;
  }
  next();
});

// Method to share with user
emotionSchema.methods.shareWith = function(userId, message = '') {
  // Check if already shared with this user
  const existingShare = this.sharing.sharedWith.find(share => 
    share.user.toString() === userId.toString()
  );
  
  if (!existingShare) {
    this.sharing.sharedWith.push({
      user: userId,
      sharedAt: new Date(),
      message: message
    });
    this.sharing.isShared = true;
    // Remove expiration when shared
    this.expiresAt = undefined;
  }
};

// Method to unshare with user
emotionSchema.methods.unshareWith = function(userId) {
  this.sharing.sharedWith = this.sharing.sharedWith.filter(share => 
    share.user.toString() !== userId.toString()
  );
  
  // If no more shares, mark as not shared
  if (this.sharing.sharedWith.length === 0) {
    this.sharing.isShared = false;
    // Reset expiration
    this.expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
  }
};

// Method to add reaction
emotionSchema.methods.addReaction = function(userId, reactionType) {
  // Remove existing reaction from this user
  this.reactions = this.reactions.filter(reaction => 
    reaction.user.toString() !== userId.toString()
  );
  
  // Add new reaction
  this.reactions.push({
    user: userId,
    reaction: reactionType,
    createdAt: new Date()
  });
};

// Method to remove reaction
emotionSchema.methods.removeReaction = function(userId) {
  this.reactions = this.reactions.filter(reaction => 
    reaction.user.toString() !== userId.toString()
  );
};

// Method to check if user can access
emotionSchema.methods.canAccess = function(userId) {
  // Owner can always access
  if (this.user.toString() === userId.toString()) {
    return true;
  }
  
  // Check if shared with user
  if (this.sharing.isShared) {
    return this.sharing.sharedWith.some(share => 
      share.user.toString() === userId.toString()
    ) || this.sharing.isPublic;
  }
  
  return false;
};

// Static method to get emotions for user
emotionSchema.statics.getEmotionsForUser = function(userId, page = 1, limit = 20) {
  const skip = (page - 1) * limit;
  
  return this.find({
    user: userId,
    isDeleted: false
  })
  .sort({ createdAt: -1 })
  .skip(skip)
  .limit(limit)
  .populate('user', 'name email avatar');
};

// Static method to get shared emotions for user
emotionSchema.statics.getSharedEmotionsForUser = function(userId, page = 1, limit = 20) {
  const skip = (page - 1) * limit;
  
  return this.find({
    $or: [
      { 'sharing.sharedWith.user': userId },
      { 'sharing.isPublic': true }
    ],
    isDeleted: false
  })
  .sort({ createdAt: -1 })
  .skip(skip)
  .limit(limit)
  .populate('user', 'name email avatar');
};

// Static method to get emotion statistics for user
emotionSchema.statics.getEmotionStatsForUser = function(userId, days = 30) {
  const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
  
  return this.aggregate([
    {
      $match: {
        user: userId,
        createdAt: { $gte: startDate },
        isDeleted: false
      }
    },
    {
      $group: {
        _id: '$detectedEmotion.primary',
        count: { $sum: 1 },
        avgConfidence: { $avg: '$detectedEmotion.confidence' }
      }
    },
    {
      $sort: { count: -1 }
    }
  ]);
};

module.exports = mongoose.model('Emotion', emotionSchema);