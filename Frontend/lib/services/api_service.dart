import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/emotion.dart';
import '../models/notification.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const bool mockMode = true; // Set to false when backend is ready

  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _setupInterceptors();
    _loadTokens();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            if (await _refreshAccessToken()) {
              // Retry the request
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_accessToken';
              try {
                final response = await _dio.fetch(opts);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, continue with original error
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': _refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
    } catch (e) {
      await _clearTokens();
    }
    return false;
  }

  // Authentication
  Future<ApiResponse<AuthResponse>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (mockMode) {
      // Mock registration
      await Future.delayed(const Duration(seconds: 1));
      final mockUser = _createMockUser(name, email);
      await _saveTokens('mock_access_token', 'mock_refresh_token');
      return ApiResponse.success(AuthResponse(
        user: mockUser,
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
      ));
    }

    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final data = response.data['data'];
        await _saveTokens(data['accessToken'], data['refreshToken']);
        return ApiResponse.success(AuthResponse.fromJson(data));
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Registration failed');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    if (mockMode) {
      // Mock login
      await Future.delayed(const Duration(seconds: 1));
      if (email == 'demo@chatfun.com' && password == 'demo123') {
        final mockUser = _createMockUser('Demo User', email);
        await _saveTokens('mock_access_token', 'mock_refresh_token');
        return ApiResponse.success(AuthResponse(
          user: mockUser,
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
        ));
      } else {
        return ApiResponse.error('Invalid email or password');
      }
    }

    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _saveTokens(data['accessToken'], data['refreshToken']);
        return ApiResponse.success(AuthResponse.fromJson(data));
      }
      return ApiResponse.error(response.data['message'] ?? 'Login failed');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post('/auth/logout', data: {
        'refreshToken': _refreshToken,
      });
      await _clearTokens();
      return ApiResponse.success(null);
    } catch (e) {
      await _clearTokens();
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      if (response.statusCode == 200) {
        return ApiResponse.success(
            User.fromJson(response.data['data']['user']));
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get user');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Users
  Future<ApiResponse<List<User>>> searchUsers(String query) async {
    try {
      final response = await _dio.get('/users/search', queryParameters: {
        'q': query,
      });

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data['data']['users'];
        final users = usersJson.map((json) => User.fromJson(json)).toList();
        return ApiResponse.success(users);
      }
      return ApiResponse.error(response.data['message'] ?? 'Search failed');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<void>> sendFriendRequest(String userId) async {
    try {
      final response = await _dio.post('/users/$userId/friend-request');
      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to send friend request');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<void>> acceptFriendRequest(String userId) async {
    try {
      final response = await _dio.post('/users/$userId/accept-friend');
      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to accept friend request');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Chats
  Future<ApiResponse<List<Chat>>> getChats() async {
    try {
      final response = await _dio.get('/chats');
      if (response.statusCode == 200) {
        final List<dynamic> chatsJson = response.data['data']['chats'];
        final chats = chatsJson.map((json) => Chat.fromJson(json)).toList();
        return ApiResponse.success(chats);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get chats');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Chat>> createChat({
    required List<String> participants,
    String? name,
    String type = 'private',
  }) async {
    try {
      final response = await _dio.post('/chats', data: {
        'participants': participants,
        'name': name,
        'type': type,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
            Chat.fromJson(response.data['data']['chat']));
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to create chat');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<Message>>> getChatMessages(String chatId,
      {int page = 1}) async {
    try {
      final response =
          await _dio.get('/chats/$chatId/messages', queryParameters: {
        'page': page,
      });

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data['data']['messages'];
        final messages =
            messagesJson.map((json) => Message.fromJson(json)).toList();
        return ApiResponse.success(messages);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get messages');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Message>> sendMessage({
    required String chatId,
    required Map<String, dynamic> content,
    required String type,
    String? replyTo,
  }) async {
    try {
      final response = await _dio.post('/chats/$chatId/messages', data: {
        'content': content,
        'type': type,
        'replyTo': replyTo,
      });

      if (response.statusCode == 201) {
        return ApiResponse.success(
            Message.fromJson(response.data['data']['message']));
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to send message');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Emotions
  Future<ApiResponse<Emotion>> detectEmotion(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post('/emotions/detect', data: formData);

      if (response.statusCode == 201) {
        return ApiResponse.success(
            Emotion.fromJson(response.data['data']['emotion']));
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to detect emotion');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<Emotion>>> getEmotions({int page = 1}) async {
    try {
      final response = await _dio.get('/emotions', queryParameters: {
        'page': page,
      });

      if (response.statusCode == 200) {
        final List<dynamic> emotionsJson = response.data['data']['emotions'];
        final emotions =
            emotionsJson.map((json) => Emotion.fromJson(json)).toList();
        return ApiResponse.success(emotions);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get emotions');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<void>> shareEmotion({
    required String emotionId,
    required List<String> recipients,
    String? message,
  }) async {
    try {
      final response = await _dio.post('/emotions/$emotionId/share', data: {
        'recipients': recipients,
        'message': message,
      });

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to share emotion');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Notifications
  Future<ApiResponse<List<NotificationModel>>> getNotifications(
      {int page = 1}) async {
    try {
      final response = await _dio.get('/notifications', queryParameters: {
        'page': page,
      });

      if (response.statusCode == 200) {
        final List<dynamic> notificationsJson =
            response.data['data']['notifications'];
        final notifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        return ApiResponse.success(notifications);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get notifications');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<int>> getUnreadNotificationCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data['data']['unreadCount']);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get unread count');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // File Upload
  Future<ApiResponse<String>> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post('/upload/avatar', data: formData);

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data['data']['avatarUrl']);
      }
      return ApiResponse.error(
          response.data['message'] ?? 'Failed to upload avatar');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response!.data['message'] ?? 'An error occurred';
      } else {
        return 'Network error. Please check your connection.';
      }
    }
    return error.toString();
  }

  User _createMockUser(String name, String email) {
    return User(
      id: 'mock_user_id',
      name: name,
      email: email,
      avatar: null,
      isOnline: true,
      lastSeen: DateTime.now(),
      bio: 'Demo user for ChatFun app',
      friends: [],
      friendRequests: FriendRequests(sent: [], received: []),
      emotionStats: EmotionStats(
        totalEmotions: 0,
        emotionCounts: EmotionCounts.empty(),
      ),
      settings: UserSettings.defaultSettings(),
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  bool get isAuthenticated => _accessToken != null;
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;
  ApiResponse.error(this.error)
      : success = false,
        data = null;
}

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
