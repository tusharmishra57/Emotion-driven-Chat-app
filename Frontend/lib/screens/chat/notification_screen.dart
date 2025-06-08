import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.message,
      title: 'New message from Alice',
      message: 'Hey! Check out this emotion 😊',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      avatar: '👩‍🦰',
      actionData: {'chatId': 'chat_1', 'userName': 'Alice Johnson'},
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.friendRequest,
      title: 'Friend request from Bob',
      message: 'Bob Smith wants to be your friend',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      avatar: '👨‍🦱',
      actionData: {'userId': 'user_2', 'userName': 'Bob Smith'},
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.emotionShared,
      title: 'Carol shared an emotion',
      message: 'Carol shared a happy Ghibli expression with you',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      avatar: '👩‍🦳',
      actionData: {'emotionId': 'emotion_3', 'userName': 'Carol Davis'},
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.system,
      title: 'New feature available!',
      message: 'Try our new emotion recognition improvements',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      avatar: '🎉',
      actionData: {},
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.achievement,
      title: 'Achievement unlocked!',
      message: 'You\'ve shared 50 emotions this month',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      avatar: '🏆',
      actionData: {},
    ),
  ];

  List<NotificationItem> get _unreadNotifications =>
      _allNotifications.where((n) => !n.isRead).toList();

  List<NotificationItem> get _readNotifications =>
      _allNotifications.where((n) => n.isRead).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPurple,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppTheme.primaryPurple,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_rounded),
            color: AppTheme.primaryPurple,
            onPressed: _markAllAsRead,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            color: AppTheme.primaryPurple,
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _clearAllNotifications();
                  break;
                case 'settings':
                  _openNotificationSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.clear_all_rounded),
                    const SizedBox(width: 8),
                    Text('Clear All', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_rounded),
                    const SizedBox(width: 8),
                    Text('Settings', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryPurple,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              text: 'All (${_allNotifications.length})',
            ),
            Tab(
              text: 'Unread (${_unreadNotifications.length})',
            ),
            Tab(
              text: 'Read (${_readNotifications.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(_allNotifications),
          _buildNotificationsList(_unreadNotifications),
          _buildNotificationsList(_readNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Theme.of(context).colorScheme.surface
            : AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.withOpacity(0.2)
              : AppTheme.primaryPurple.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    _getNotificationColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      _getNotificationColor(notification.type).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: notification.type == NotificationType.system ||
                        notification.type == NotificationType.achievement
                    ? Text(
                        notification.avatar,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Text(
                        notification.avatar,
                        style: const TextStyle(fontSize: 24),
                      ),
              ),
            ),
            if (!notification.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getNotificationIcon(notification.type),
                  size: 14,
                  color: _getNotificationColor(notification.type),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: Colors.grey[400],
          ),
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                _markAsRead(notification);
                break;
              case 'mark_unread':
                _markAsUnread(notification);
                break;
              case 'delete':
                _deleteNotification(notification);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read_rounded),
                    const SizedBox(width: 8),
                    Text('Mark as read', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            if (notification.isRead)
              PopupMenuItem(
                value: 'mark_unread',
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_unread_rounded),
                    const SizedBox(width: 8),
                    Text('Mark as unread', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return AppTheme.primaryBlue;
      case NotificationType.friendRequest:
        return AppTheme.primaryGreen;
      case NotificationType.emotionShared:
        return AppTheme.primaryOrange;
      case NotificationType.system:
        return AppTheme.primaryPurple;
      case NotificationType.achievement:
        return AppTheme.primaryPink;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Icons.chat_bubble_rounded;
      case NotificationType.friendRequest:
        return Icons.person_add_rounded;
      case NotificationType.emotionShared:
        return Icons.face_retouching_natural;
      case NotificationType.system:
        return Icons.info_rounded;
      case NotificationType.achievement:
        return Icons.emoji_events_rounded;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // Handle different notification types
    switch (notification.type) {
      case NotificationType.message:
        final chatId = notification.actionData['chatId'] as String?;
        final userName = notification.actionData['userName'] as String?;
        if (chatId != null && userName != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                userName: userName,
              ),
            ),
          );
        }
        break;
      case NotificationType.friendRequest:
        _showFriendRequestDialog(notification);
        break;
      case NotificationType.emotionShared:
        _showEmotionDialog(notification);
        break;
      case NotificationType.system:
        _showSystemNotificationDialog(notification);
        break;
      case NotificationType.achievement:
        _showAchievementDialog(notification);
        break;
    }
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _markAsUnread(NotificationItem notification) {
    setState(() {
      notification.isRead = false;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications marked as read',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _deleteNotification(NotificationItem notification) {
    setState(() {
      _allNotifications.remove(notification);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification deleted',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryOrange,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allNotifications.add(notification);
            });
          },
        ),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear All Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allNotifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications cleared',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppTheme.primaryPurple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification settings coming soon!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _showFriendRequestDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Friend Request',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  notification.avatar,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Decline',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Friend request accepted!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text(
              'Accept',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmotionDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Emotion Shared',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Center(
                child: Text(
                  '😊',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
            ),
            child: Text(
              'View Emotion',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSystemNotificationDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          notification.message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Achievement Unlocked! 🎉',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  notification.avatar,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
            ),
            child: Text(
              'Awesome!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

enum NotificationType {
  message,
  friendRequest,
  emotionShared,
  system,
  achievement,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final String avatar;
  final Map<String, dynamic> actionData;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.avatar,
    required this.actionData,
  });
}
