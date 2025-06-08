class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final bool isOnline;
  final DateTime lastSeen;
  final String bio;
  final List<Friend> friends;
  final FriendRequests friendRequests;
  final EmotionStats emotionStats;
  final UserSettings settings;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.isOnline,
    required this.lastSeen,
    required this.bio,
    required this.friends,
    required this.friendRequests,
    required this.emotionStats,
    required this.settings,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      bio: json['bio'] ?? '',
      friends: (json['friends'] as List<dynamic>?)
          ?.map((e) => Friend.fromJson(e))
          .toList() ?? [],
      friendRequests: json['friendRequests'] != null 
          ? FriendRequests.fromJson(json['friendRequests'])
          : FriendRequests(sent: [], received: []),
      emotionStats: json['emotionStats'] != null
          ? EmotionStats.fromJson(json['emotionStats'])
          : EmotionStats(totalEmotions: 0, emotionCounts: EmotionCounts.empty()),
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'])
          : UserSettings.defaultSettings(),
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'bio': bio,
      'friends': friends.map((e) => e.toJson()).toList(),
      'friendRequests': friendRequests.toJson(),
      'emotionStats': emotionStats.toJson(),
      'settings': settings.toJson(),
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get mutualFriends => friends.length;
  String get recentEmotion => '😊'; // Default or calculate from emotion stats
}

class Friend {
  final User user;
  final DateTime addedAt;

  Friend({
    required this.user,
    required this.addedAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      user: User.fromJson(json['user']),
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class FriendRequests {
  final List<FriendRequest> sent;
  final List<FriendRequest> received;

  FriendRequests({
    required this.sent,
    required this.received,
  });

  factory FriendRequests.fromJson(Map<String, dynamic> json) {
    return FriendRequests(
      sent: (json['sent'] as List<dynamic>?)
          ?.map((e) => FriendRequest.fromJson(e))
          .toList() ?? [],
      received: (json['received'] as List<dynamic>?)
          ?.map((e) => FriendRequest.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sent': sent.map((e) => e.toJson()).toList(),
      'received': received.map((e) => e.toJson()).toList(),
    };
  }
}

class FriendRequest {
  final User user;
  final DateTime? sentAt;
  final DateTime? receivedAt;

  FriendRequest({
    required this.user,
    this.sentAt,
    this.receivedAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      user: User.fromJson(json['user']),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      receivedAt: json['receivedAt'] != null ? DateTime.parse(json['receivedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'sentAt': sentAt?.toIso8601String(),
      'receivedAt': receivedAt?.toIso8601String(),
    };
  }
}

class EmotionStats {
  final int totalEmotions;
  final EmotionCounts emotionCounts;

  EmotionStats({
    required this.totalEmotions,
    required this.emotionCounts,
  });

  factory EmotionStats.fromJson(Map<String, dynamic> json) {
    return EmotionStats(
      totalEmotions: json['totalEmotions'] ?? 0,
      emotionCounts: json['emotionCounts'] != null
          ? EmotionCounts.fromJson(json['emotionCounts'])
          : EmotionCounts.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEmotions': totalEmotions,
      'emotionCounts': emotionCounts.toJson(),
    };
  }
}

class EmotionCounts {
  final int happy;
  final int sad;
  final int angry;
  final int surprised;
  final int neutral;
  final int excited;
  final int confused;
  final int disgusted;

  EmotionCounts({
    required this.happy,
    required this.sad,
    required this.angry,
    required this.surprised,
    required this.neutral,
    required this.excited,
    required this.confused,
    required this.disgusted,
  });

  factory EmotionCounts.fromJson(Map<String, dynamic> json) {
    return EmotionCounts(
      happy: json['happy'] ?? 0,
      sad: json['sad'] ?? 0,
      angry: json['angry'] ?? 0,
      surprised: json['surprised'] ?? 0,
      neutral: json['neutral'] ?? 0,
      excited: json['excited'] ?? 0,
      confused: json['confused'] ?? 0,
      disgusted: json['disgusted'] ?? 0,
    );
  }

  factory EmotionCounts.empty() {
    return EmotionCounts(
      happy: 0,
      sad: 0,
      angry: 0,
      surprised: 0,
      neutral: 0,
      excited: 0,
      confused: 0,
      disgusted: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'happy': happy,
      'sad': sad,
      'angry': angry,
      'surprised': surprised,
      'neutral': neutral,
      'excited': excited,
      'confused': confused,
      'disgusted': disgusted,
    };
  }
}

class UserSettings {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final PreferenceSettings preferences;

  UserSettings({
    required this.notifications,
    required this.privacy,
    required this.preferences,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notifications: json['notifications'] != null
          ? NotificationSettings.fromJson(json['notifications'])
          : NotificationSettings.defaultSettings(),
      privacy: json['privacy'] != null
          ? PrivacySettings.fromJson(json['privacy'])
          : PrivacySettings.defaultSettings(),
      preferences: json['preferences'] != null
          ? PreferenceSettings.fromJson(json['preferences'])
          : PreferenceSettings.defaultSettings(),
    );
  }

  factory UserSettings.defaultSettings() {
    return UserSettings(
      notifications: NotificationSettings.defaultSettings(),
      privacy: PrivacySettings.defaultSettings(),
      preferences: PreferenceSettings.defaultSettings(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.toJson(),
      'privacy': privacy.toJson(),
      'preferences': preferences.toJson(),
    };
  }
}

class NotificationSettings {
  final bool messages;
  final bool friendRequests;
  final bool emotionShares;

  NotificationSettings({
    required this.messages,
    required this.friendRequests,
    required this.emotionShares,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      messages: json['messages'] ?? true,
      friendRequests: json['friendRequests'] ?? true,
      emotionShares: json['emotionShares'] ?? true,
    );
  }

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      messages: true,
      friendRequests: true,
      emotionShares: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages,
      'friendRequests': friendRequests,
      'emotionShares': emotionShares,
    };
  }
}

class PrivacySettings {
  final bool showOnlineStatus;
  final bool allowEmotionSharing;

  PrivacySettings({
    required this.showOnlineStatus,
    required this.allowEmotionSharing,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      allowEmotionSharing: json['allowEmotionSharing'] ?? true,
    );
  }

  factory PrivacySettings.defaultSettings() {
    return PrivacySettings(
      showOnlineStatus: true,
      allowEmotionSharing: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showOnlineStatus': showOnlineStatus,
      'allowEmotionSharing': allowEmotionSharing,
    };
  }
}

class PreferenceSettings {
  final String language;
  final String theme;

  PreferenceSettings({
    required this.language,
    required this.theme,
  });

  factory PreferenceSettings.fromJson(Map<String, dynamic> json) {
    return PreferenceSettings(
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'light',
    );
  }

  factory PreferenceSettings.defaultSettings() {
    return PreferenceSettings(
      language: 'en',
      theme: 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
    };
  }
}