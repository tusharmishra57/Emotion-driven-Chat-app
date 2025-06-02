// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const EmotionChatApp());
}

class EmotionChatApp extends StatelessWidget {
  const EmotionChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}