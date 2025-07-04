const express = require('express');
const Notification = require('../models/Notification');
const { auth } = require('../middleware/auth');
const { validateNotificationUpdate } = require('../middleware/validation');

const router = express.Router();

// @route   GET /api/notifications
// @desc    Get user's notifications
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, unreadOnly = false } = req.query;
    
    const notifications = await Notification.getNotificationsForUser(
      req.user._id,
      parseInt(page),
      parseInt(limit),
      unreadOnly === 'true'
    );

    const total = await Notification.countDocuments({
      recipient: req.user._id,
      isDeleted: false,
      ...(unreadOnly === 'true' && { isRead: false })
    });

    res.json({
      success: true,
      data: {
        notifications,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit))
        }
      }
    });

  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching notifications'
    });
  }
});

// @route   GET /api/notifications/unread-count
// @desc    Get unread notifications count
// @access  Private
router.get('/unread-count', auth, async (req, res) => {
  try {
    const count = await Notification.getUnreadCountForUser(req.user._id);

    res.json({
      success: true,
      data: { unreadCount: count }
    });

  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching unread count'
    });
  }
});

// @route   PUT /api/notifications/:id
// @desc    Update notification (mark as read/unread)
// @access  Private
router.put('/:id', auth, validateNotificationUpdate, async (req, res) => {
  try {
    const { isRead } = req.body;
    const notificationId = req.params.id;

    const notification = await Notification.findById(notificationId);
    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    // Check if user owns this notification
    if (notification.recipient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Update notification
    if (typeof isRead === 'boolean') {
      notification.isRead = isRead;
      if (isRead) {
        notification.readAt = new Date();
      } else {
        notification.readAt = undefined;
      }
    }

    await notification.save();

    res.json({
      success: true,
      message: 'Notification updated successfully',
      data: { notification }
    });

  } catch (error) {
    console.error('Update notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating notification'
    });
  }
});

// @route   PUT /api/notifications/mark-all-read
// @desc    Mark all notifications as read
// @access  Private
router.put('/mark-all-read', auth, async (req, res) => {
  try {
    const result = await Notification.markAllAsReadForUser(req.user._id);

    res.json({
      success: true,
      message: 'All notifications marked as read',
      data: { modifiedCount: result.modifiedCount }
    });

  } catch (error) {
    console.error('Mark all read error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while marking notifications as read'
    });
  }
});

// @route   DELETE /api/notifications/:id
// @desc    Delete notification
// @access  Private
router.delete('/:id', auth, async (req, res) => {
  try {
    const notificationId = req.params.id;

    const notification = await Notification.findById(notificationId);
    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    // Check if user owns this notification
    if (notification.recipient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Soft delete
    notification.isDeleted = true;
    await notification.save();

    res.json({
      success: true,
      message: 'Notification deleted successfully'
    });

  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting notification'
    });
  }
});

// @route   DELETE /api/notifications
// @desc    Delete all notifications
// @access  Private
router.delete('/', auth, async (req, res) => {
  try {
    const result = await Notification.updateMany(
      {
        recipient: req.user._id,
        isDeleted: false
      },
      {
        $set: {
          isDeleted: true
        }
      }
    );

    res.json({
      success: true,
      message: 'All notifications deleted successfully',
      data: { deletedCount: result.modifiedCount }
    });

  } catch (error) {
    console.error('Delete all notifications error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting notifications'
    });
  }
});

// @route   GET /api/notifications/types/:type
// @desc    Get notifications by type
// @access  Private
router.get('/types/:type', auth, async (req, res) => {
  try {
    const { type } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const validTypes = [
      'message',
      'friend_request',
      'friend_request_accepted',
      'emotion_shared',
      'emotion_reaction',
      'system',
      'achievement'
    ];

    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid notification type'
      });
    }

    const notifications = await Notification.find({
      recipient: req.user._id,
      type: type,
      isDeleted: false
    })
    .populate('sender', 'name email avatar')
    .populate('data.chatId', 'name type')
    .populate('data.emotionId', 'detectedEmotion ghibliArt')
    .sort({ createdAt: -1 })
    .skip((parseInt(page) - 1) * parseInt(limit))
    .limit(parseInt(limit));

    const total = await Notification.countDocuments({
      recipient: req.user._id,
      type: type,
      isDeleted: false
    });

    res.json({
      success: true,
      data: {
        notifications,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit))
        }
      }
    });

  } catch (error) {
    console.error('Get notifications by type error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching notifications'
    });
  }
});

// @route   GET /api/notifications/summary
// @desc    Get notification summary (counts by type)
// @access  Private
router.get('/summary', auth, async (req, res) => {
  try {
    const summary = await Notification.aggregate([
      {
        $match: {
          recipient: req.user._id,
          isDeleted: false
        }
      },
      {
        $group: {
          _id: '$type',
          total: { $sum: 1 },
          unread: {
            $sum: {
              $cond: [{ $eq: ['$isRead', false] }, 1, 0]
            }
          }
        }
      },
      {
        $sort: { total: -1 }
      }
    ]);

    // Get overall totals
    const overallStats = await Notification.aggregate([
      {
        $match: {
          recipient: req.user._id,
          isDeleted: false
        }
      },
      {
        $group: {
          _id: null,
          totalNotifications: { $sum: 1 },
          unreadNotifications: {
            $sum: {
              $cond: [{ $eq: ['$isRead', false] }, 1, 0]
            }
          }
        }
      }
    ]);

    res.json({
      success: true,
      data: {
        summary,
        overall: overallStats[0] || { totalNotifications: 0, unreadNotifications: 0 }
      }
    });

  } catch (error) {
    console.error('Get notification summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching notification summary'
    });
  }
});

module.exports = router;