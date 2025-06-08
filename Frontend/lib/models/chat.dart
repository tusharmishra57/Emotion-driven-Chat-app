import 'user.dart';
import 'message.dart';

class Chat {
  final String id;
  final List<User> participants;
  final String type; // 'private' or 'group'
  final String? name;
  final String? description;
  final String? avatar;
  final Message? lastMessage;
  final DateTime lastActivity;
  final User? admin;
  final bool isActive;
  final int unreadCount;
  final List<TypingIndicator> typingIndicators;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    required this.id,
    required this.participants,
    required this.type,
    this.name,
    this.description,
    this.avatar,
    this.lastMessage,
    required this.lastActivity,
    this.admin,
    required this.isActive,
    required this.unreadCount,
    required this.typingIndicators,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? json['id'],
      participants: (json['participants'] as List<dynamic>)
          .map((e) => User.fromJson(e))
          .toList(),
      type: json['type'],
      name: json['name'],
      description: json['description'],
      avatar: json['avatar'],
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      lastActivity: DateTime.parse(json['lastActivity']),
      admin: json['admin'] != null ? User.fromJson(json['admin']) : null,
      isActive: json['isActive'] ?? true,
      unreadCount: json['unreadCount'] ?? 0,
      typingIndicators: (json['typingIndicators'] as List<dynamic>?)
          ?.map((e) => TypingIndicator.fromJson(e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants.map((e) => e.toJson()).toList(),
      'type': type,
      'name': name,
      'description': description,
      'avatar': avatar,
      'lastMessage': lastMessage?.toJson(),
      'lastActivity': lastActivity.toIso8601String(),
      'admin': admin?.toJson(),
      'isActive': isActive,
      'unreadCount': unreadCount,
      'typingIndicators': typingIndicators.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    if (type == 'group') {
      return name ?? 'Group Chat';
    } else {
      // For private chats, return the other participant's name
      // This assumes the current user is filtered out elsewhere
      return participants.isNotEmpty ? participants.first.name : 'Chat';
    }
  }

  String? get displayAvatar {
    if (type == 'group') {
      return avatar;
    } else {
      // For private chats, return the other participant's avatar
      return participants.isNotEmpty ? participants.first.avatar : null;
    }
  }

  bool get isOnline {
    if (type == 'group') {
      return participants.any((user) => user.isOnline);
    } else {
      return participants.isNotEmpty ? participants.first.isOnline : false;
    }
  }

  DateTime? get lastSeen {
    if (type == 'group') {
      return null; // Groups don't have a single last seen
    } else {
      return participants.isNotEmpty ? participants.first.lastSeen : null;
    }
  }

  List<User> get activeTypingUsers {
    return typingIndicators
        .where((indicator) => indicator.isTyping)
        .map((indicator) => indicator.user)
        .toList();
  }
}

class TypingIndicator {
  final User user;
  final bool isTyping;
  final DateTime timestamp;

  TypingIndicator({
    required this.user,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      user: User.fromJson(json['user']),
      isTyping: json['isTyping'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'isTyping': isTyping,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}