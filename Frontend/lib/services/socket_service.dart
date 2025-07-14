import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/user.dart';
import '../models/message.dart';

class SocketService extends ChangeNotifier {
  static SocketService? _instance;
  static SocketService get instance => _instance ??= SocketService._();
  
  SocketService._();

  // Use production URL for Vercel deployment
  static const String socketUrl = 'https://chatfun-app.vercel.app';
  // For local development, use:
  // static const String socketUrl = 'http://localhost:3000';

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _authToken;

  // Stream controllers for real-time events
  final _messageStreamController = StreamController<Message>.broadcast();
  final _userJoinedStreamController = StreamController<UserJoinedEvent>.broadcast();
  final _userOnlineStreamController = StreamController<UserOnlineEvent>.broadcast();
  final _userOfflineStreamController = StreamController<UserOfflineEvent>.broadcast();
  final _typingStreamController = StreamController<TypingEvent>.broadcast();

  // Getters for streams
  Stream<Message> get messageStream => _messageStreamController.stream;
  Stream<UserJoinedEvent> get userJoinedStream => _userJoinedStreamController.stream;
  Stream<UserOnlineEvent> get userOnlineStream => _userOnlineStreamController.stream;
  Stream<UserOfflineEvent> get userOfflineStream => _userOfflineStreamController.stream;
  Stream<TypingEvent> get typingStream => _typingStreamController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect(String userId, String authToken) async {
    if (_socket != null && _isConnected) {
      await disconnect();
    }

    _currentUserId = userId;
    _authToken = authToken;

    _socket = IO.io(socketUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build());

    _setupEventHandlers();
    
    _socket!.connect();
    
    // Wait for connection with timeout
    await _waitForConnection();
    
    // Authenticate after connection
    _socket!.emit('authenticate', {
      'token': authToken,
    });
  }

  Future<void> _waitForConnection() async {
    final completer = Completer<void>();
    Timer? timeout;

    void onConnect() {
      _isConnected = true;
      notifyListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
      timeout?.cancel();
    }

    void onError(dynamic error) {
      _isConnected = false;
      notifyListeners();
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
      timeout?.cancel();
    }

    _socket!.on('connect', (_) => onConnect());
    _socket!.on('connect_error', (error) => onError(error));

    timeout = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.completeError('Connection timeout');
      }
    });

    return completer.future;
  }

  void _setupEventHandlers() {
    _socket!.on('connect', (_) {
      _isConnected = true;
      notifyListeners();
      debugPrint('🔗 Connected to ChatFun server');
    });

    _socket!.on('disconnect', (_) {
      _isConnected = false;
      notifyListeners();
      debugPrint('🔌 Disconnected from ChatFun server');
    });

    _socket!.on('authenticated', (data) {
      debugPrint('✅ Socket authenticated successfully');
    });

    _socket!.on('authentication_failed', (data) {
      debugPrint('❌ Socket authentication failed: ${data['error']}');
    });

    _socket!.on('user_joined', (data) {
      debugPrint('🎉 User joined: ${data['user']['name']}');
      final event = UserJoinedEvent.fromJson(data);
      _userJoinedStreamController.add(event);
    });

    _socket!.on('user_online', (data) {
      debugPrint('🟢 User online: ${data['name']}');
      final event = UserOnlineEvent.fromJson(data);
      _userOnlineStreamController.add(event);
    });

    _socket!.on('user_offline', (data) {
      debugPrint('🔴 User offline: ${data['name']}');
      final event = UserOfflineEvent.fromJson(data);
      _userOfflineStreamController.add(event);
    });

    _socket!.on('new_message', (data) {
      debugPrint('💬 New message received');
      try {
        final message = Message.fromJson(data['message']);
        _messageStreamController.add(message);
      } catch (e) {
        debugPrint('Error parsing message: $e');
      }
    });

    _socket!.on('user_typing', (data) {
      debugPrint('⌨️ User typing: ${data['name']}');
      final event = TypingEvent.fromJson(data);
      _typingStreamController.add(event);
    });

    _socket!.on('error', (error) {
      debugPrint('❌ Socket error: $error');
    });
  }

  // Chat methods
  void joinChat(String chatId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_chat', {'chatId': chatId});
      debugPrint('📨 Joined chat: $chatId');
    }
  }

  void leaveChat(String chatId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave_chat', {'chatId': chatId});
      debugPrint('📤 Left chat: $chatId');
    }
  }

  void startTyping(String chatId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing_start', {'chatId': chatId});
    }
  }

  void stopTyping(String chatId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing_stop', {'chatId': chatId});
    }
  }

  Future<void> disconnect() async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    _currentUserId = null;
    _authToken = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _messageStreamController.close();
    _userJoinedStreamController.close();
    _userOnlineStreamController.close();
    _userOfflineStreamController.close();
    _typingStreamController.close();
    super.dispose();
  }
}

// Event classes
class UserJoinedEvent {
  final User user;
  final String message;
  final DateTime timestamp;

  UserJoinedEvent({
    required this.user,
    required this.message,
    required this.timestamp,
  });

  factory UserJoinedEvent.fromJson(Map<String, dynamic> json) {
    return UserJoinedEvent(
      user: User.fromJson(json['user']),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class UserOnlineEvent {
  final String userId;
  final String name;
  final DateTime timestamp;

  UserOnlineEvent({
    required this.userId,
    required this.name,
    required this.timestamp,
  });

  factory UserOnlineEvent.fromJson(Map<String, dynamic> json) {
    return UserOnlineEvent(
      userId: json['userId'],
      name: json['name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class UserOfflineEvent {
  final String userId;
  final String name;
  final DateTime timestamp;

  UserOfflineEvent({
    required this.userId,
    required this.name,
    required this.timestamp,
  });

  factory UserOfflineEvent.fromJson(Map<String, dynamic> json) {
    return UserOfflineEvent(
      userId: json['userId'],
      name: json['name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class TypingEvent {
  final String userId;
  final String name;
  final String chatId;
  final bool isTyping;

  TypingEvent({
    required this.userId,
    required this.name,
    required this.chatId,
    required this.isTyping,
  });

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      userId: json['userId'],
      name: json['name'],
      chatId: json['chatId'],
      isTyping: json['isTyping'],
    );
  }
}