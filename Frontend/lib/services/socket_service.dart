import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/message.dart';
import '../models/user.dart';

class SocketService {
  static const String serverUrl = 'http://localhost:3000';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  IO.Socket? _socket;
  bool _isConnected = false;
  
  // Stream controllers for real-time events
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<TypingEvent> _typingController = StreamController<TypingEvent>.broadcast();
  final StreamController<UserStatusEvent> _userStatusController = StreamController<UserStatusEvent>.broadcast();
  final StreamController<NotificationEvent> _notificationController = StreamController<NotificationEvent>.broadcast();

  // Getters for streams
  Stream<Message> get messageStream => _messageController.stream;
  Stream<TypingEvent> get typingStream => _typingController.stream;
  Stream<UserStatusEvent> get userStatusStream => _userStatusController.stream;
  Stream<NotificationEvent> get notificationStream => _notificationController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No authentication token found');
    }

    _socket = IO.io(serverUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setAuth({'token': token})
        .build());

    _setupEventListeners();
    _socket!.connect();
  }

  void _setupEventListeners() {
    _socket!.onConnect((_) {
      print('Connected to server');
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from server');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('Connection error: $error');
      _isConnected = false;
    });

    // Message events
    _socket!.on('new_message', (data) {
      try {
        final message = Message.fromJson(data['message']);
        _messageController.add(message);
      } catch (e) {
        print('Error parsing new message: $e');
      }
    });

    // Typing events
    _socket!.on('user_typing', (data) {
      try {
        final typingEvent = TypingEvent.fromJson(data);
        _typingController.add(typingEvent);
      } catch (e) {
        print('Error parsing typing event: $e');
      }
    });

    // User status events
    _socket!.on('user_online', (data) {
      try {
        final event = UserStatusEvent(
          userId: data['userId'],
          user: User.fromJson(data['user']),
          isOnline: true,
        );
        _userStatusController.add(event);
      } catch (e) {
        print('Error parsing user online event: $e');
      }
    });

    _socket!.on('user_offline', (data) {
      try {
        final event = UserStatusEvent(
          userId: data['userId'],
          isOnline: false,
          lastSeen: DateTime.parse(data['lastSeen']),
        );
        _userStatusController.add(event);
      } catch (e) {
        print('Error parsing user offline event: $e');
      }
    });

    // Friend request events
    _socket!.on('friend_request_received', (data) {
      try {
        final event = NotificationEvent(
          type: 'friend_request',
          data: data,
        );
        _notificationController.add(event);
      } catch (e) {
        print('Error parsing friend request event: $e');
      }
    });

    // Emotion sharing events
    _socket!.on('emotion_shared', (data) {
      try {
        final event = NotificationEvent(
          type: 'emotion_shared',
          data: data,
        );
        _notificationController.add(event);
      } catch (e) {
        print('Error parsing emotion shared event: $e');
      }
    });

    // Message reactions
    _socket!.on('message_reaction', (data) {
      // Handle message reaction updates
      print('Message reaction: $data');
    });

    // Messages read
    _socket!.on('messages_read', (data) {
      // Handle messages read status
      print('Messages read: $data');
    });

    // Error handling
    _socket!.on('error', (data) {
      print('Socket error: $data');
    });
  }

  // Chat operations
  void joinChat(String chatId) {
    if (_isConnected) {
      _socket!.emit('join_chat', {'chatId': chatId});
    }
  }

  void leaveChat(String chatId) {
    if (_isConnected) {
      _socket!.emit('leave_chat', {'chatId': chatId});
    }
  }

  void sendMessage({
    required String chatId,
    required Map<String, dynamic> content,
    required String type,
    String? replyTo,
  }) {
    if (_isConnected) {
      _socket!.emit('send_message', {
        'chatId': chatId,
        'content': content,
        'type': type,
        'replyTo': replyTo,
      });
    }
  }

  void startTyping(String chatId) {
    if (_isConnected) {
      _socket!.emit('typing_start', {'chatId': chatId});
    }
  }

  void stopTyping(String chatId) {
    if (_isConnected) {
      _socket!.emit('typing_stop', {'chatId': chatId});
    }
  }

  void addReaction({
    required String messageId,
    required String emoji,
  }) {
    if (_isConnected) {
      _socket!.emit('add_reaction', {
        'messageId': messageId,
        'emoji': emoji,
      });
    }
  }

  void markMessagesRead(String chatId) {
    if (_isConnected) {
      _socket!.emit('mark_messages_read', {'chatId': chatId});
    }
  }

  // Friend operations
  void sendFriendRequest(String targetUserId) {
    if (_isConnected) {
      _socket!.emit('send_friend_request', {'targetUserId': targetUserId});
    }
  }

  // Emotion operations
  void shareEmotion({
    required String emotionId,
    required List<String> recipients,
  }) {
    if (_isConnected) {
      _socket!.emit('share_emotion', {
        'emotionId': emotionId,
        'recipients': recipients,
      });
    }
  }

  // Notification operations
  void markNotificationRead(String notificationId) {
    if (_isConnected) {
      _socket!.emit('mark_notification_read', {'notificationId': notificationId});
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _userStatusController.close();
    _notificationController.close();
  }
}

class TypingEvent {
  final String chatId;
  final User user;
  final bool isTyping;

  TypingEvent({
    required this.chatId,
    required this.user,
    required this.isTyping,
  });

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      chatId: json['chatId'],
      user: User.fromJson(json['user']),
      isTyping: json['isTyping'],
    );
  }
}

class UserStatusEvent {
  final String userId;
  final User? user;
  final bool isOnline;
  final DateTime? lastSeen;

  UserStatusEvent({
    required this.userId,
    this.user,
    required this.isOnline,
    this.lastSeen,
  });
}

class NotificationEvent {
  final String type;
  final Map<String, dynamic> data;

  NotificationEvent({
    required this.type,
    required this.data,
  });
}