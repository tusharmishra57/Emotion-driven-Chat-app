import 'user.dart';
import 'emotion.dart';

class Message {
  final String id;
  final String chat;
  final User sender;
  final MessageContent content;
  final String type;
  final Message? replyTo;
  final List<MessageReaction> reactions;
  final Map<String, int> reactionCounts;
  final List<ReadStatus> readBy;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final User? deletedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.chat,
    required this.sender,
    required this.content,
    required this.type,
    this.replyTo,
    required this.reactions,
    required this.reactionCounts,
    required this.readBy,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.deletedAt,
    this.deletedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'],
      chat: json['chat'],
      sender: User.fromJson(json['sender']),
      content: MessageContent.fromJson(json['content']),
      type: json['type'],
      replyTo: json['replyTo'] != null ? Message.fromJson(json['replyTo']) : null,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReaction.fromJson(e))
          .toList() ?? [],
      reactionCounts: Map<String, int>.from(json['reactionCounts'] ?? {}),
      readBy: (json['readBy'] as List<dynamic>?)
          ?.map((e) => ReadStatus.fromJson(e))
          .toList() ?? [],
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      deletedBy: json['deletedBy'] != null ? User.fromJson(json['deletedBy']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chat': chat,
      'sender': sender.toJson(),
      'content': content.toJson(),
      'type': type,
      'replyTo': replyTo?.toJson(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'reactionCounts': reactionCounts,
      'readBy': readBy.map((e) => e.toJson()).toList(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Legacy properties for backward compatibility
  String get senderId => sender.id;
  String get senderName => sender.name;
  DateTime get timestamp => createdAt;
  String? get replyToId => replyTo?.id;
  String? get replyToContent => replyTo?.content.text;
  String get text => content.text ?? '';
  bool get isMe => false; // This should be determined by comparing with current user
  bool get isRead => readBy.isNotEmpty;
  bool get isDelivered => true;
  String? get imageUrl => content.file?.url;
  String? get audioUrl => content.file?.url;
  MessageType get messageType {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      case 'emotion':
        return MessageType.sticker;
      default:
        return MessageType.text;
    }
  }

  String get displayContent {
    if (isDeleted) {
      return 'This message was deleted';
    }
    
    switch (type) {
      case 'text':
        return content.text ?? '';
      case 'emotion':
        return 'Shared an emotion';
      case 'image':
        return 'Sent an image';
      case 'video':
        return 'Sent a video';
      case 'audio':
        return 'Sent an audio message';
      case 'file':
        return 'Sent a file';
      default:
        return 'Sent a message';
    }
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

  Message copyWith({
    String? id,
    String? chat,
    User? sender,
    MessageContent? content,
    String? type,
    Message? replyTo,
    List<MessageReaction>? reactions,
    Map<String, int>? reactionCounts,
    List<ReadStatus>? readBy,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    User? deletedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      chat: chat ?? this.chat,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      readBy: readBy ?? this.readBy,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MessageContent {
  final String? text;
  final Emotion? emotion;
  final MessageFile? file;

  MessageContent({
    this.text,
    this.emotion,
    this.file,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      text: json['text'],
      emotion: json['emotion'] != null ? Emotion.fromJson(json['emotion']) : null,
      file: json['file'] != null ? MessageFile.fromJson(json['file']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'emotion': emotion?.toJson(),
      'file': file?.toJson(),
    };
  }
}

class MessageFile {
  final String url;
  final String filename;
  final String mimeType;
  final int size;

  MessageFile({
    required this.url,
    required this.filename,
    required this.mimeType,
    required this.size,
  });

  factory MessageFile.fromJson(Map<String, dynamic> json) {
    return MessageFile(
      url: json['url'],
      filename: json['filename'],
      mimeType: json['mimeType'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'filename': filename,
      'mimeType': mimeType,
      'size': size,
    };
  }
}

class MessageReaction {
  final User user;
  final String emoji;
  final DateTime reactedAt;

  MessageReaction({
    required this.user,
    required this.emoji,
    required this.reactedAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      user: User.fromJson(json['user']),
      emoji: json['emoji'],
      reactedAt: DateTime.parse(json['reactedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'emoji': emoji,
      'reactedAt': reactedAt.toIso8601String(),
    };
  }
}

class ReadStatus {
  final User user;
  final DateTime readAt;

  ReadStatus({
    required this.user,
    required this.readAt,
  });

  factory ReadStatus.fromJson(Map<String, dynamic> json) {
    return ReadStatus(
      user: User.fromJson(json['user']),
      readAt: DateTime.parse(json['readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'readAt': readAt.toIso8601String(),
    };
  }
}

enum MessageType {
  text,
  image,
  audio,
  video,
  file,
  sticker,
  location,
}