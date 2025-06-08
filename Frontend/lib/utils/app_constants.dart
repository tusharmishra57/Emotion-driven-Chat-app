class AppConstants {
  // App Information
  static const String appName = 'ChatFun';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Emotion-Driven Chat Application with Personalized Ghibli-Style Expression Sharing';

  // Support Information
  static const String supportEmail = 'support@chatfun.com';
  static const String websiteUrl = 'https://chatfun.com';
  static const String privacyPolicyUrl = 'https://chatfun.com/privacy';
  static const String termsOfServiceUrl = 'https://chatfun.com/terms';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // UI Constants
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;

  static const double padding = 20.0;
  static const double smallPadding = 12.0;
  static const double largePadding = 32.0;

  // Emotion Recognition
  static const List<String> supportedEmotions = [
    'Happy',
    'Sad',
    'Angry',
    'Surprised',
    'Neutral',
    'Excited',
    'Confused',
    'Disgusted',
  ];

  static const Map<String, String> emotionEmojis = {
    'Happy': '😊',
    'Sad': '😢',
    'Angry': '😡',
    'Surprised': '😮',
    'Neutral': '😐',
    'Excited': '🤩',
    'Confused': '🤔',
    'Disgusted': '🤢',
  };

  // Ghibli-style Art Mappings
  static const Map<String, String> ghibliEmotions = {
    'Happy': '🌟',
    'Sad': '🌧️',
    'Angry': '⚡',
    'Surprised': '✨',
    'Neutral': '🌸',
    'Excited': '🎆',
    'Confused': '🌀',
    'Disgusted': '🍃',
  };

  // Chat Constants
  static const int maxMessageLength = 500;
  static const int maxEmotionsPerDay = 100;
  static const Duration typingIndicatorDelay = Duration(seconds: 2);

  // File Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';

  // Error Messages
  static const String networkErrorMessage =
      'No internet connection. Please check your network settings.';
  static const String serverErrorMessage =
      'Server error occurred. Please try again later.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String permissionErrorMessage =
      'Permission required. Please enable camera access in settings.';

  // Success Messages
  static const String emotionSharedMessage = 'Emotion shared successfully! 🎉';
  static const String friendAddedMessage = 'Friend added successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String settingsSavedMessage = 'Settings saved successfully!';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;

  // Regular Expressions
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String usernameRegex = r'^[a-zA-Z0-9_]{3,30}$';

  // SharedPreferences Keys
  static const String isFirstTimeKey = 'is_first_time';
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // API Endpoints (for future implementation)
  static const String baseUrl = 'https://api.chatfun.com/v1';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String chatsEndpoint = '/chats';
  static const String emotionsEndpoint = '/emotions';

  // Feature Flags
  static const bool enableEmotionRecognition = true;
  static const bool enableGhibliArt = true;
  static const bool enableVoiceMessages = false;
  static const bool enableVideoCall = false;

  // Limits
  static const int maxFriends = 1000;
  static const int maxChatsPerUser = 100;
  static const int maxEmotionHistoryDays = 30;

  // Tips and Hints
  static const List<String> onboardingTips = [
    'Express with Ghibli Magic - Transform your emotions into beautiful artwork',
    'Real-time Emotion Detection - Our AI captures your expressions instantly',
    'Privacy First - You control what you share with confirmation prompts',
    'Connect & Chat - Start meaningful conversations with authentic expressions',
  ];

  static const List<String> loadingTips = [
    '🎨 Creating beautiful Ghibli-style expressions',
    '😊 Analyzing your emotions with AI',
    '💬 Preparing your chat experience',
    '✨ Adding magical touches to your messages',
    '🌟 Almost ready for fun conversations!',
  ];

  // Notification Types
  static const String messageNotificationType = 'message';
  static const String friendRequestNotificationType = 'friend_request';
  static const String emotionSharedNotificationType = 'emotion_shared';
  static const String systemNotificationType = 'system';
  static const String achievementNotificationType = 'achievement';
}
