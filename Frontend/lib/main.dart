import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/emotion_recognition_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/users_list_screen.dart';
import 'screens/error_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ChatFunApp());
}

class ChatFunApp extends StatelessWidget {
  const ChatFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatFun - Emotion-Driven Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/emotion-recognition': (context) => const EmotionRecognitionScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/users': (context) => const UsersListScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/error': (context) => const ErrorScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes like chat screens
        if (settings.name?.startsWith('/chat/') == true) {
          final uri = Uri.parse(settings.name!);
          final chatId = uri.pathSegments[1];
          final userName = uri.queryParameters['userName'] ?? 'Unknown User';

          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              userName: userName,
            ),
          );
        }

        // Handle unknown routes
        return MaterialPageRoute(
          builder: (context) => const NotFoundErrorScreen(),
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundErrorScreen(),
        );
      },
    );
  }
}
