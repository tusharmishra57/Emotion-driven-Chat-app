// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // Ghibli-inspired color palette
  static const Color primary = Color(0xFF7BA05B); // Forest green
  static const Color primaryLight = Color(0xFF9BC17A);
  static const Color primaryDark = Color(0xFF5E8043);
  
  static const Color secondary = Color(0xFFE8B4A0); // Warm peach
  static const Color secondaryLight = Color(0xFFF0C7B6);
  static const Color secondaryDark = Color(0xFFD69E85);
  
  static const Color accent = Color(0xFF6B9BD1); // Sky blue
  static const Color accentLight = Color(0xFF8BB0DA);
  static const Color accentDark = Color(0xFF4A7FB8);
  
  static const Color background = Color(0xFFF8F6F0); // Cream white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C2C2C);
  
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFDDD8D3);
  
  static const Color error = Color(0xFFE17055);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFE77F3E);
  
  // Dark theme colors
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color primaryDarkTheme = Color(0xFF8FB86F);
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDarkTheme,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSecondary: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textLight,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
      ),
    );
  }
}

class AppSizes {
  static const double padding = 16.0;
  static const double margin = 16.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double buttonHeight = 48.0;
}

class AppStrings {
  static const String appName = 'Emotion Chat';
  static const String tagline = 'Express emotions in Ghibli style';
  static const String welcomeBack = 'Welcome Back!';
  static const String createAccount = 'Create Account';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String or = 'OR';
}