import 'user.dart';

class NotificationModel {
  final String id;
  final User recipient;
  final User? sender;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final String priority;
  final String category;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    this.sender,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.readAt,
    required this.priority,
    required this.category,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'],
      recipient: User.fromJson(json['recipient']),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      priority: json['priority'] ?? 'medium',
      category: json['category'] ?? 'general',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipient': recipient.toJson(),
      'sender': sender?.toJson(),
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'priority': priority,
      'category': category,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get displayMessage {
    if (sender != null) {
      return '${sender!.name} $message';
    }
    return message;
  }

  NotificationIcon get icon {
    switch (type) {
      case 'message':
        return NotificationIcon.message;
      case 'friend_request':
        return NotificationIcon.friendRequest;
      case 'friend_request_accepted':
        return NotificationIcon.friendAccepted;
      case 'emotion_shared':
        return NotificationIcon.emotionShared;
      case 'emotion_reaction':
        return NotificationIcon.emotionReaction;
      case 'system':
        return NotificationIcon.system;
      case 'achievement':
        return NotificationIcon.achievement;
      default:
        return NotificationIcon.general;
    }
  }
}

enum NotificationIcon {
  message,
  friendRequest,
  friendAccepted,
  emotionShared,
  emotionReaction,
  system,
  achievement,
  general,
}