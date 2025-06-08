import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/emotion.dart';
import '../models/notification.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  User? _currentUser;
  List<Chat> _chats = [];
  List<Message> _messages = [];
  List<Emotion> _emotions = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  List<Emotion> get emotions => _emotions;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _apiService.isAuthenticated;

  AppProvider() {
    _initializeSocketListeners();
  }

  void _initializeSocketListeners() {
    _socketService.messageStream.listen((message) {
      _messages.add(message);
      notifyListeners();
    });

    _socketService.userStatusStream.listen((event) {
      // Update user status in chats
      for (var chat in _chats) {
        for (var participant in chat.participants) {
          if (participant.id == event.userId) {
            // Update participant status
            notifyListeners();
            break;
          }
        }
      }
    });

    _socketService.notificationStream.listen((event) {
      // Handle real-time notifications
      _loadNotifications();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Authentication
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.login(email: email, password: password);
      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        await _socketService.connect();
        await _loadInitialData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );
      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        await _socketService.connect();
        await _loadInitialData();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
      _socketService.disconnect();
      _currentUser = null;
      _chats.clear();
      _messages.clear();
      _emotions.clear();
      _notifications.clear();
    } catch (e) {
      _setError(e.toString());
    }
    
    _setLoading(false);
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadChats(),
      _loadEmotions(),
      _loadNotifications(),
    ]);
  }

  // Chats
  Future<void> _loadChats() async {
    try {
      final response = await _apiService.getChats();
      if (response.success && response.data != null) {
        _chats = response.data!;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadChatMessages(String chatId) async {
    try {
      final response = await _apiService.getChatMessages(chatId);
      if (response.success && response.data != null) {
        _messages = response.data!;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
  }) async {
    try {
      final messageContent = {'text': content};
      final response = await _apiService.sendMessage(
        chatId: chatId,
        content: messageContent,
        type: type,
      );
      
      if (response.success && response.data != null) {
        // Message will be added via socket listener
      } else {
        _setError(response.error);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Emotions
  Future<void> _loadEmotions() async {
    try {
      final response = await _apiService.getEmotions();
      if (response.success && response.data != null) {
        _emotions = response.data!;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<Emotion?> detectEmotion(dynamic imageFile) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.detectEmotion(imageFile);
      if (response.success && response.data != null) {
        _emotions.insert(0, response.data!);
        _setLoading(false);
        notifyListeners();
        return response.data;
      } else {
        _setError(response.error);
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  // Notifications
  Future<void> _loadNotifications() async {
    try {
      final response = await _apiService.getNotifications();
      if (response.success && response.data != null) {
        _notifications = response.data!;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  int get unreadNotificationCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Users
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiService.searchUsers(query);
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.error);
        return [];
      }
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  Future<bool> sendFriendRequest(String userId) async {
    try {
      final response = await _apiService.sendFriendRequest(userId);
      if (response.success) {
        return true;
      } else {
        _setError(response.error);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String userId) async {
    try {
      final response = await _apiService.acceptFriendRequest(userId);
      if (response.success) {
        // Reload current user to get updated friend list
        await _loadCurrentUser();
        return true;
      } else {
        _setError(response.error);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      if (response.success && response.data != null) {
        _currentUser = response.data!;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}