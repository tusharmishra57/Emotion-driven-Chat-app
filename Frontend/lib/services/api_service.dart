import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/api_response.dart';

class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Use production URL for Vercel deployment
  static const String baseUrl = 'https://chatfun-app.vercel.app/api';
  // For local development, use:
  // static const String baseUrl = 'http://localhost:3000/api';
  
  late Dio _dio;
  String? _accessToken;

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
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, logout user
            logout();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
  }

  Future<void> _saveTokens(String accessToken) async {
    _accessToken = accessToken;
    await _storage.write(key: 'access_token', value: accessToken);
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    await _storage.deleteAll();
  }

  // Health check
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error('Health check failed: ${e.toString()}');
    }
  }

  // Authentication
  Future<ApiResponse<AuthResponse>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final token = response.data['data']['token'];
        await _saveTokens(token);
        
        return ApiResponse.success(AuthResponse(
          user: User.fromJson(response.data['data']['user']),
          token: token,
        ));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (e is DioException) {
        final message = e.response?.data['message'] ?? 'Registration failed';
        return ApiResponse.error(message);
      }
      return ApiResponse.error('Registration failed: ${e.toString()}');
    }
  }

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final token = response.data['data']['token'];
        await _saveTokens(token);
        
        return ApiResponse.success(AuthResponse(
          user: User.fromJson(response.data['data']['user']),
          token: token,
        ));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is DioException) {
        final message = e.response?.data['message'] ?? 'Login failed';
        return ApiResponse.error(message);
      }
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _clearTokens();
  }

  // User operations
  Future<ApiResponse<User>> getProfile() async {
    try {
      await _loadTokens();
      final response = await _dio.get('/users/profile');
      
      if (response.data['success']) {
        return ApiResponse.success(User.fromJson(response.data['data']['user']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      return ApiResponse.error('Failed to get profile: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<User>>> getOnlineUsers() async {
    try {
      await _loadTokens();
      final response = await _dio.get('/users/online');
      
      if (response.data['success']) {
        final users = (response.data['data']['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
        return ApiResponse.success(users);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get online users');
      }
    } catch (e) {
      return ApiResponse.error('Failed to get online users: ${e.toString()}');
    }
  }

  // Chat operations
  Future<ApiResponse<List<Chat>>> getChats() async {
    try {
      await _loadTokens();
      final response = await _dio.get('/chats');
      
      if (response.data['success']) {
        final chats = (response.data['data']['chats'] as List)
            .map((json) => Chat.fromJson(json))
            .toList();
        return ApiResponse.success(chats);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get chats');
      }
    } catch (e) {
      return ApiResponse.error('Failed to get chats: ${e.toString()}');
    }
  }

  Future<ApiResponse<Chat>> createOrGetChat(String participantId) async {
    try {
      await _loadTokens();
      final response = await _dio.post('/chats', data: {
        'participantId': participantId,
      });
      
      if (response.data['success']) {
        return ApiResponse.success(Chat.fromJson(response.data['data']['chat']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to create chat');
      }
    } catch (e) {
      return ApiResponse.error('Failed to create chat: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<Message>>> getMessages(String chatId, {int page = 1}) async {
    try {
      await _loadTokens();
      final response = await _dio.get('/chats/$chatId/messages', queryParameters: {
        'page': page,
        'limit': 50,
      });
      
      if (response.data['success']) {
        final messages = (response.data['data']['messages'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
        return ApiResponse.success(messages);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get messages');
      }
    } catch (e) {
      return ApiResponse.error('Failed to get messages: ${e.toString()}');
    }
  }

  Future<ApiResponse<Message>> sendMessage({
    required String chatId,
    required Map<String, dynamic> content,
    String type = 'text',
  }) async {
    try {
      await _loadTokens();
      final response = await _dio.post('/chats/$chatId/messages', data: {
        'content': content,
        'type': type,
      });
      
      if (response.data['success']) {
        return ApiResponse.success(Message.fromJson(response.data['data']['message']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      return ApiResponse.error('Failed to send message: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    await _loadTokens();
    return _accessToken != null;
  }

  // Get stored token
  Future<String?> getToken() async {
    await _loadTokens();
    return _accessToken;
  }
}

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });
}