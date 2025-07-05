const express = require('express');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { auth } = require('../middleware/auth');
const { validateUpdateProfile } = require('../middleware/validation');

const router = express.Router();

// @route   GET /api/users/search
// @desc    Search users
// @access  Private
router.get('/search', auth, async (req, res) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;
    
    if (!q || q.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Search query must be at least 2 characters'
      });
    }

    const users = await User.findBySearchQuery(q.trim(), req.user._id)
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    res.json({
      success: true,
      data: {
        users: users.map(user => user.getPublicProfile()),
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: users.length
        }
      }
    });

  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while searching users'
    });
  }
});

// @route   GET /api/users/:id
// @desc    Get user profile
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .populate('friends.user', 'name email avatar isOnline lastSeen');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if current user is friends with this user
    const isFriend = user.isFriendWith(req.user._id);
    const hasSentRequest = user.friendRequests.received.some(
      request => request.user.toString() === req.user._id.toString()
    );
    const hasReceivedRequest = user.friendRequests.sent.some(
      request => request.user.toString() === req.user._id.toString()
    );

    const userProfile = user.getPublicProfile();
    userProfile.relationship = {
      isFriend,
      hasSentRequest,
      hasReceivedRequest
    };

    res.json({
      success: true,
      data: {
        user: userProfile
      }
    });

  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching user profile'
    });
  }
});

// @route   PUT /api/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, validateUpdateProfile, async (req, res) => {
  try {
    const { name, bio, email } = req.body;
    const user = req.user;

    // Check if email is being changed and if it's already taken
    if (email && email !== user.email) {
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Email is already taken'
        });
      }
      user.email = email;
      user.isVerified = false; // Reset verification if email changes
    }

    if (name) user.name = name;
    if (bio !== undefined) user.bio = bio;

    await user.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        user: user.getPublicProfile()
      }
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating profile'
    });
  }
});

// @route   POST /api/users/:id/friend-request
// @desc    Send friend request
// @access  Private
router.post('/:id/friend-request', auth, async (req, res) => {
  try {
    const targetUserId = req.params.id;
    const currentUser = req.user;

    if (targetUserId === currentUser._id.toString()) {
      return res.status(400).json({
        success: false,
        message: 'Cannot send friend request to yourself'
      });
    }

    const targetUser = await User.findById(targetUserId);
    if (!targetUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if already friends
    if (currentUser.isFriendWith(targetUserId)) {
      return res.status(400).json({
        success: false,
        message: 'Already friends with this user'
      });
    }

    // Check if request already sent
    const existingRequest = targetUser.friendRequests.received.find(
      request => request.user.toString() === currentUser._id.toString()
    );

    if (existingRequest) {
      return res.status(400).json({
        success: false,
        message: 'Friend request already sent'
      });
    }

    // Add friend request
    targetUser.friendRequests.received.push({
      user: currentUser._id,
      receivedAt: new Date()
    });

    currentUser.friendRequests.sent.push({
      user: targetUserId,
      sentAt: new Date()
    });

    await Promise.all([targetUser.save(), currentUser.save()]);

    // Create notification
    await Notification.createFriendRequestNotification(currentUser._id, targetUserId);

    res.json({
      success: true,
      message: 'Friend request sent successfully'
    });

  } catch (error) {
    console.error('Send friend request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while sending friend request'
    });
  }
});

// @route   POST /api/users/:id/accept-friend
// @desc    Accept friend request
// @access  Private
router.post('/:id/accept-friend', auth, async (req, res) => {
  try {
    const senderUserId = req.params.id;
    const currentUser = req.user;

    const senderUser = await User.findById(senderUserId);
    if (!senderUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if friend request exists
    const requestIndex = currentUser.friendRequests.received.findIndex(
      request => request.user.toString() === senderUserId
    );

    if (requestIndex === -1) {
      return res.status(400).json({
        success: false,
        message: 'No friend request found from this user'
      });
    }

    // Add to friends list
    currentUser.addFriend(senderUserId);
    senderUser.addFriend(currentUser._id);

    // Remove friend requests
    currentUser.friendRequests.received.splice(requestIndex, 1);
    const sentRequestIndex = senderUser.friendRequests.sent.findIndex(
      request => request.user.toString() === currentUser._id.toString()
    );
    if (sentRequestIndex !== -1) {
      senderUser.friendRequests.sent.splice(sentRequestIndex, 1);
    }

    await Promise.all([currentUser.save(), senderUser.save()]);

    // Create notification for sender
    await Notification.createNotification({
      recipient: senderUserId,
      sender: currentUser._id,
      type: 'friend_request_accepted',
      title: 'Friend Request Accepted',
      message: 'accepted your friend request',
      priority: 'medium',
      category: 'social'
    });

    res.json({
      success: true,
      message: 'Friend request accepted successfully'
    });

  } catch (error) {
    console.error('Accept friend request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while accepting friend request'
    });
  }
});

// @route   POST /api/users/:id/reject-friend
// @desc    Reject friend request
// @access  Private
router.post('/:id/reject-friend', auth, async (req, res) => {
  try {
    const senderUserId = req.params.id;
    const currentUser = req.user;

    const senderUser = await User.findById(senderUserId);
    if (!senderUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Remove friend request
    const requestIndex = currentUser.friendRequests.received.findIndex(
      request => request.user.toString() === senderUserId
    );

    if (requestIndex === -1) {
      return res.status(400).json({
        success: false,
        message: 'No friend request found from this user'
      });
    }

    currentUser.friendRequests.received.splice(requestIndex, 1);

    const sentRequestIndex = senderUser.friendRequests.sent.findIndex(
      request => request.user.toString() === currentUser._id.toString()
    );
    if (sentRequestIndex !== -1) {
      senderUser.friendRequests.sent.splice(sentRequestIndex, 1);
    }

    await Promise.all([currentUser.save(), senderUser.save()]);

    res.json({
      success: true,
      message: 'Friend request rejected successfully'
    });

  } catch (error) {
    console.error('Reject friend request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while rejecting friend request'
    });
  }
});

// @route   DELETE /api/users/:id/unfriend
// @desc    Remove friend
// @access  Private
router.delete('/:id/unfriend', auth, async (req, res) => {
  try {
    const friendUserId = req.params.id;
    const currentUser = req.user;

    const friendUser = await User.findById(friendUserId);
    if (!friendUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if they are friends
    if (!currentUser.isFriendWith(friendUserId)) {
      return res.status(400).json({
        success: false,
        message: 'Not friends with this user'
      });
    }

    // Remove from friends list
    currentUser.removeFriend(friendUserId);
    friendUser.removeFriend(currentUser._id);

    await Promise.all([currentUser.save(), friendUser.save()]);

    res.json({
      success: true,
      message: 'Friend removed successfully'
    });

  } catch (error) {
    console.error('Unfriend error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while removing friend'
    });
  }
});

// @route   GET /api/users/friends
// @desc    Get user's friends list
// @access  Private
router.get('/friends', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    
    const user = await User.findById(req.user._id)
      .populate({
        path: 'friends.user',
        select: 'name email avatar isOnline lastSeen bio',
        options: {
          skip: (parseInt(page) - 1) * parseInt(limit),
          limit: parseInt(limit)
        }
      });

    res.json({
      success: true,
      data: {
        friends: user.friends.map(friend => ({
          ...friend.user.getPublicProfile(),
          friendsSince: friend.addedAt
        })),
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: user.friends.length
        }
      }
    });

  } catch (error) {
    console.error('Get friends error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching friends'
    });
  }
});

// @route   GET /api/users/friend-requests
// @desc    Get friend requests
// @access  Private
router.get('/friend-requests', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .populate('friendRequests.received.user', 'name email avatar bio')
      .populate('friendRequests.sent.user', 'name email avatar bio');

    res.json({
      success: true,
      data: {
        received: user.friendRequests.received.map(request => ({
          user: request.user.getPublicProfile(),
          receivedAt: request.receivedAt
        })),
        sent: user.friendRequests.sent.map(request => ({
          user: request.user.getPublicProfile(),
          sentAt: request.sentAt
        }))
      }
    });

  } catch (error) {
    console.error('Get friend requests error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching friend requests'
    });
  }
});

// @route   PUT /api/users/settings
// @desc    Update user settings
// @access  Private
router.put('/settings', auth, async (req, res) => {
  try {
    const { notifications, privacy, preferences } = req.body;
    const user = req.user;

    if (notifications) {
      user.settings.notifications = { ...user.settings.notifications, ...notifications };
    }

    if (privacy) {
      user.settings.privacy = { ...user.settings.privacy, ...privacy };
    }

    if (preferences) {
      user.settings.preferences = { ...user.settings.preferences, ...preferences };
    }

    await user.save();

    res.json({
      success: true,
      message: 'Settings updated successfully',
      data: {
        settings: user.settings
      }
    });

  } catch (error) {
    console.error('Update settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating settings'
    });
  }
});

module.exports = router;