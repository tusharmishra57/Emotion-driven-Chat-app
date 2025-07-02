const express = require('express');
const multer = require('multer');
const sharp = require('sharp');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');
const Emotion = require('../models/Emotion');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { auth } = require('../middleware/auth');
const { validateEmotionShare } = require('../middleware/validation');

const router = express.Router();

// Configure multer for image uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, and GIF are allowed.'), false);
    }
  }
});

// Mock emotion detection function (replace with actual API call)
const detectEmotion = async (imageBuffer) => {
  // Simulate API call delay
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // Mock emotion detection results
  const emotions = [
    { emotion: 'happy', confidence: 0.85 },
    { emotion: 'excited', confidence: 0.12 },
    { emotion: 'neutral', confidence: 0.03 }
  ];
  
  return {
    primary: emotions[0].emotion,
    confidence: emotions[0].confidence,
    allEmotions: emotions
  };
};

// Mock Ghibli art generation function (replace with actual API call)
const generateGhibliArt = async (emotion, imageBuffer) => {
  // Simulate API call delay
  await new Promise(resolve => setTimeout(resolve, 3000));
  
  // Mock Ghibli art URL (in real implementation, this would be generated)
  const artUrl = `https://example.com/ghibli-art/${uuidv4()}.png`;
  
  return {
    url: artUrl,
    style: 'ghibli',
    prompt: `A ${emotion} expression in Studio Ghibli art style`,
    generationTime: 3
  };
};

// @route   POST /api/emotions/detect
// @desc    Detect emotion from uploaded image
// @access  Private
router.post('/detect', auth, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Image file is required'
      });
    }

    const startTime = Date.now();

    // Process image with Sharp
    const processedImage = await sharp(req.file.buffer)
      .resize(512, 512, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toBuffer();

    // Mock image upload to cloud storage (replace with actual implementation)
    const imageUrl = `https://example.com/uploads/${uuidv4()}.jpg`;

    // Detect emotion
    const emotionResult = await detectEmotion(processedImage);

    // Generate Ghibli art
    const ghibliArt = await generateGhibliArt(emotionResult.primary, processedImage);

    const processingTime = (Date.now() - startTime) / 1000;

    // Create emotion record
    const emotion = new Emotion({
      user: req.user._id,
      originalImage: {
        url: imageUrl,
        filename: req.file.originalname,
        size: req.file.size,
        mimeType: req.file.mimetype
      },
      detectedEmotion: emotionResult,
      ghibliArt,
      metadata: {
        faceDetected: true,
        faceCount: 1,
        imageQuality: 'high',
        processingTime,
        apiVersion: '1.0'
      }
    });

    await emotion.save();

    // Update user emotion stats
    req.user.updateEmotionStats(emotionResult.primary);
    await req.user.save();

    res.status(201).json({
      success: true,
      message: 'Emotion detected successfully',
      data: { emotion }
    });

  } catch (error) {
    console.error('Emotion detection error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during emotion detection'
    });
  }
});

// @route   GET /api/emotions
// @desc    Get user's emotions
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, emotion } = req.query;
    
    let query = {
      user: req.user._id,
      isDeleted: false
    };

    if (emotion) {
      query['detectedEmotion.primary'] = emotion;
    }

    const emotions = await Emotion.find(query)
      .sort({ createdAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit))
      .populate('user', 'name email avatar');

    const total = await Emotion.countDocuments(query);

    res.json({
      success: true,
      data: {
        emotions,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit))
        }
      }
    });

  } catch (error) {
    console.error('Get emotions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching emotions'
    });
  }
});

// @route   GET /api/emotions/shared
// @desc    Get emotions shared with user
// @access  Private
router.get('/shared', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    
    const emotions = await Emotion.getSharedEmotionsForUser(
      req.user._id,
      parseInt(page),
      parseInt(limit)
    );

    res.json({
      success: true,
      data: {
        emotions,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: emotions.length
        }
      }
    });

  } catch (error) {
    console.error('Get shared emotions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching shared emotions'
    });
  }
});

// @route   GET /api/emotions/stats
// @desc    Get emotion statistics
// @access  Private
router.get('/stats', auth, async (req, res) => {
  try {
    const { days = 30 } = req.query;
    
    const stats = await Emotion.getEmotionStatsForUser(req.user._id, parseInt(days));
    
    // Get total emotions count
    const totalEmotions = await Emotion.countDocuments({
      user: req.user._id,
      isDeleted: false
    });

    // Get recent emotions
    const recentEmotions = await Emotion.find({
      user: req.user._id,
      isDeleted: false
    })
    .sort({ createdAt: -1 })
    .limit(10)
    .select('detectedEmotion.primary createdAt');

    res.json({
      success: true,
      data: {
        stats,
        totalEmotions,
        recentEmotions: recentEmotions.map(e => ({
          emotion: e.detectedEmotion.primary,
          date: e.createdAt
        }))
      }
    });

  } catch (error) {
    console.error('Get emotion stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching emotion statistics'
    });
  }
});

// @route   GET /api/emotions/:id
// @desc    Get specific emotion
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const emotion = await Emotion.findById(req.params.id)
      .populate('user', 'name email avatar')
      .populate('reactions.user', 'name email avatar');

    if (!emotion) {
      return res.status(404).json({
        success: false,
        message: 'Emotion not found'
      });
    }

    // Check if user can access this emotion
    if (!emotion.canAccess(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    res.json({
      success: true,
      data: { emotion }
    });

  } catch (error) {
    console.error('Get emotion error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching emotion'
    });
  }
});

// @route   POST /api/emotions/:id/share
// @desc    Share emotion with users
// @access  Private
router.post('/:id/share', auth, validateEmotionShare, async (req, res) => {
  try {
    const { recipients, message } = req.body;
    const emotionId = req.params.id;

    const emotion = await Emotion.findById(emotionId);
    if (!emotion) {
      return res.status(404).json({
        success: false,
        message: 'Emotion not found'
      });
    }

    // Check if user owns this emotion
    if (emotion.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only share your own emotions'
      });
    }

    // Verify recipients exist and are friends
    const users = await User.find({ _id: { $in: recipients } });
    if (users.length !== recipients.length) {
      return res.status(400).json({
        success: false,
        message: 'One or more recipients not found'
      });
    }

    // Check friendship status
    const nonFriends = users.filter(user => !req.user.isFriendWith(user._id));
    if (nonFriends.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'You can only share emotions with friends'
      });
    }

    // Share emotion with each recipient
    const sharePromises = recipients.map(async (recipientId) => {
      emotion.shareWith(recipientId, message);
      
      // Create notification
      return Notification.createEmotionSharedNotification(
        req.user._id,
        recipientId,
        emotionId
      );
    });

    await Promise.all(sharePromises);
    await emotion.save();

    res.json({
      success: true,
      message: 'Emotion shared successfully',
      data: {
        sharedWith: emotion.sharing.sharedWith.length,
        recipients: recipients.length
      }
    });

  } catch (error) {
    console.error('Share emotion error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while sharing emotion'
    });
  }
});

// @route   POST /api/emotions/:id/react
// @desc    Add reaction to emotion
// @access  Private
router.post('/:id/react', auth, async (req, res) => {
  try {
    const { reaction } = req.body;
    const emotionId = req.params.id;

    if (!['like', 'love', 'laugh', 'wow', 'sad', 'angry'].includes(reaction)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid reaction type'
      });
    }

    const emotion = await Emotion.findById(emotionId);
    if (!emotion) {
      return res.status(404).json({
        success: false,
        message: 'Emotion not found'
      });
    }

    // Check if user can access this emotion
    if (!emotion.canAccess(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Add reaction
    emotion.addReaction(req.user._id, reaction);
    await emotion.save();

    // Create notification for emotion owner (if not reacting to own emotion)
    if (emotion.user.toString() !== req.user._id.toString()) {
      await Notification.createNotification({
        recipient: emotion.user,
        sender: req.user._id,
        type: 'emotion_reaction',
        title: 'Emotion Reaction',
        message: `reacted ${reaction} to your emotion`,
        data: { emotionId },
        priority: 'low',
        category: 'social'
      });
    }

    res.json({
      success: true,
      message: 'Reaction added successfully',
      data: {
        reactions: emotion.reactions,
        reactionCounts: emotion.reactionCounts
      }
    });

  } catch (error) {
    console.error('Add emotion reaction error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while adding reaction'
    });
  }
});

// @route   DELETE /api/emotions/:id/react
// @desc    Remove reaction from emotion
// @access  Private
router.delete('/:id/react', auth, async (req, res) => {
  try {
    const emotionId = req.params.id;

    const emotion = await Emotion.findById(emotionId);
    if (!emotion) {
      return res.status(404).json({
        success: false,
        message: 'Emotion not found'
      });
    }

    // Check if user can access this emotion
    if (!emotion.canAccess(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Remove reaction
    emotion.removeReaction(req.user._id);
    await emotion.save();

    res.json({
      success: true,
      message: 'Reaction removed successfully',
      data: {
        reactions: emotion.reactions,
        reactionCounts: emotion.reactionCounts
      }
    });

  } catch (error) {
    console.error('Remove emotion reaction error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while removing reaction'
    });
  }
});

// @route   DELETE /api/emotions/:id
// @desc    Delete emotion
// @access  Private
router.delete('/:id', auth, async (req, res) => {
  try {
    const emotion = await Emotion.findById(req.params.id);
    if (!emotion) {
      return res.status(404).json({
        success: false,
        message: 'Emotion not found'
      });
    }

    // Check if user owns this emotion
    if (emotion.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own emotions'
      });
    }

    // Soft delete
    emotion.isDeleted = true;
    emotion.deletedAt = new Date();
    await emotion.save();

    res.json({
      success: true,
      message: 'Emotion deleted successfully'
    });

  } catch (error) {
    console.error('Delete emotion error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting emotion'
    });
  }
});

// @route   POST /api/emotions/:id/unshare/:userId
// @desc    Unshare emotion with specific user
// @access  Private
router.post('/:id/unshare/:userId', auth, async (req, res) => {
  try {
    const { id: emotionId, userId } = req.params;

    const emotion = await Emotion.findById(emotionId);
    if (!emotion) {
      return res.status(404).json({
        success: false,
        message: 'Emotion not found'
      });
    }

    // Check if user owns this emotion
    if (emotion.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only unshare your own emotions'
      });
    }

    // Unshare with user
    emotion.unshareWith(userId);
    await emotion.save();

    res.json({
      success: true,
      message: 'Emotion unshared successfully'
    });

  } catch (error) {
    console.error('Unshare emotion error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while unsharing emotion'
    });
  }
});

module.exports = router;