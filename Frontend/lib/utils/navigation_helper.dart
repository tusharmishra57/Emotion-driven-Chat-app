import 'package:flutter/material.dart';
import '../screens/chat/home_screen.dart';
import '../screens/chat/emotion_recognition_screen.dart';
import '../screens/chat/profile_screen.dart';
import '../screens/chat/settings_screen.dart';
import '../screens/chat/users_list_screen.dart';
import '../screens/chat/notifications_screen.dart';
import '../screens/chat/loading_screen.dart';
import '../screens/chat/error_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/chat/chat_screen.dart';

class NavigationHelper {
  // Navigation methods for easy routing throughout the app

  static void goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  static void goToSignup(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  static void goToWelcome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  static void goToEmotionRecognition(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmotionRecognitionScreen()),
    );
  }

  static void goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  static void goToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  static void goToUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UsersListScreen()),
    );
  }

  static void goToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  static void goToChat(BuildContext context, String chatId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          userName: userName,
        ),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void showErrorScreen(
    BuildContext context, {
    String? errorMessage,
    String? errorCode,
    VoidCallback? onRetry,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorScreen(
          errorMessage: errorMessage,
          errorCode: errorCode,
          onRetry: onRetry,
        ),
      ),
    );
  }

  // Utility methods for common navigation patterns

  static void pushAndClearStack(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  static void pushWithFadeTransition(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static void pushWithSlideTransition(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static void showBottomSheet(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => content,
    );
  }

  static void showCustomDialog(BuildContext context, Widget dialog) {
    showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  // Back navigation with confirmation
  static Future<bool> showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit ChatFun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
