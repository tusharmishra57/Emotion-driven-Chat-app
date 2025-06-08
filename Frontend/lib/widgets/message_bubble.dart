import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;
  final bool showTimestamp;
  final String? currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTimestamp = false,
    this.currentUserId,
  });

  bool get isMe =>
      message.sender.id == currentUserId || message.sender.id == 'me';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Timestamp
        if (showTimestamp) _buildTimestamp(),

        // Message Bubble
        Container(
          margin: EdgeInsets.only(
            top: 4,
            bottom: showAvatar ? 8 : 2,
            left: isMe ? 50 : 0,
            right: isMe ? 0 : 50,
          ),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Other user avatar
              if (!isMe && showAvatar) _buildAvatar(),
              if (!isMe && !showAvatar) const SizedBox(width: 40),

              // Message content
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [
                              AppTheme.primaryPurple,
                              AppTheme.primaryPink,
                            ],
                          )
                        : null,
                    color: isMe ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(
                        isMe || !showAvatar ? 20 : 4,
                      ),
                      bottomRight: Radius.circular(
                        !isMe || !showAvatar ? 20 : 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? AppTheme.primaryPurple.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text
                      Text(
                        message.text,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isMe ? Colors.white : Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Time and status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey.shade500,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead
                                  ? Icons.done_all
                                  : message.isDelivered
                                      ? Icons.done_all
                                      : Icons.done,
                              size: 14,
                              color: message.isRead
                                  ? AppTheme.primaryBlue
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // My avatar
              if (isMe && showAvatar) _buildMyAvatar(),
              if (isMe && !showAvatar) const SizedBox(width: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDate(message.timestamp),
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildMyAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    }
  }
}
