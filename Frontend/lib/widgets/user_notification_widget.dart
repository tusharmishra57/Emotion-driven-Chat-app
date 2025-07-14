import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/server_config.dart';

class UserNotificationWidget extends StatefulWidget {
  final UserNotificationEvent event;
  final VoidCallback? onDismiss;

  const UserNotificationWidget({
    Key? key,
    required this.event,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<UserNotificationWidget> createState() => _UserNotificationWidgetState();
}

class _UserNotificationWidgetState extends State<UserNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
    
    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismissNotification();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissNotification() {
    _animationController.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverInfo = ServerConfig.getServerById(widget.event.serverId);
    final isJoined = widget.event.type == UserNotificationType.joined;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Color(serverInfo.color).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(serverInfo.color).withOpacity(0.1),
                    backgroundImage: widget.event.user.avatar != null
                        ? NetworkImage(widget.event.user.avatar!)
                        : null,
                    child: widget.event.user.avatar == null
                        ? Icon(
                            Icons.person,
                            color: Color(serverInfo.color),
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isJoined ? Icons.login : Icons.logout,
                              size: 16,
                              color: isJoined ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isJoined ? 'User Joined' : 'User Left',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isJoined ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: widget.event.user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: isJoined ? ' joined from ' : ' left from ',
                              ),
                              TextSpan(
                                text: serverInfo.name,
                                style: TextStyle(
                                  color: Color(serverInfo.color),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTimestamp(widget.event.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Dismiss button
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.grey[400],
                    onPressed: _dismissNotification,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Event classes
class UserNotificationEvent {
  final User user;
  final String serverId;
  final UserNotificationType type;
  final DateTime timestamp;

  UserNotificationEvent({
    required this.user,
    required this.serverId,
    required this.type,
    required this.timestamp,
  });
}

enum UserNotificationType {
  joined,
  left,
}