import 'user.dart';

class Emotion {
  final String id;
  final User user;
  final OriginalImage originalImage;
  final DetectedEmotion detectedEmotion;
  final GhibliArt ghibliArt;
  final EmotionMetadata metadata;
  final EmotionSharing sharing;
  final List<EmotionReaction> reactions;
  final Map<String, int> reactionCounts;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Emotion({
    required this.id,
    required this.user,
    required this.originalImage,
    required this.detectedEmotion,
    required this.ghibliArt,
    required this.metadata,
    required this.sharing,
    required this.reactions,
    required this.reactionCounts,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      id: json['_id'] ?? json['id'],
      user: User.fromJson(json['user']),
      originalImage: OriginalImage.fromJson(json['originalImage']),
      detectedEmotion: DetectedEmotion.fromJson(json['detectedEmotion']),
      ghibliArt: GhibliArt.fromJson(json['ghibliArt']),
      metadata: EmotionMetadata.fromJson(json['metadata']),
      sharing: EmotionSharing.fromJson(json['sharing']),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => EmotionReaction.fromJson(e))
          .toList() ?? [],
      reactionCounts: Map<String, int>.from(json['reactionCounts'] ?? {}),
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'originalImage': originalImage.toJson(),
      'detectedEmotion': detectedEmotion.toJson(),
      'ghibliArt': ghibliArt.toJson(),
      'metadata': metadata.toJson(),
      'sharing': sharing.toJson(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'reactionCounts': reactionCounts,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class OriginalImage {
  final String url;
  final String filename;
  final int size;
  final String mimeType;

  OriginalImage({
    required this.url,
    required this.filename,
    required this.size,
    required this.mimeType,
  });

  factory OriginalImage.fromJson(Map<String, dynamic> json) {
    return OriginalImage(
      url: json['url'],
      filename: json['filename'],
      size: json['size'],
      mimeType: json['mimeType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'filename': filename,
      'size': size,
      'mimeType': mimeType,
    };
  }
}

class DetectedEmotion {
  final String primary;
  final double confidence;
  final List<EmotionResult> allEmotions;

  DetectedEmotion({
    required this.primary,
    required this.confidence,
    required this.allEmotions,
  });

  factory DetectedEmotion.fromJson(Map<String, dynamic> json) {
    return DetectedEmotion(
      primary: json['primary'],
      confidence: json['confidence'].toDouble(),
      allEmotions: (json['allEmotions'] as List<dynamic>)
          .map((e) => EmotionResult.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'confidence': confidence,
      'allEmotions': allEmotions.map((e) => e.toJson()).toList(),
    };
  }
}

class EmotionResult {
  final String emotion;
  final double confidence;

  EmotionResult({
    required this.emotion,
    required this.confidence,
  });

  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    return EmotionResult(
      emotion: json['emotion'],
      confidence: json['confidence'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'confidence': confidence,
    };
  }
}

class GhibliArt {
  final String url;
  final String style;
  final String prompt;
  final double generationTime;

  GhibliArt({
    required this.url,
    required this.style,
    required this.prompt,
    required this.generationTime,
  });

  factory GhibliArt.fromJson(Map<String, dynamic> json) {
    return GhibliArt(
      url: json['url'],
      style: json['style'],
      prompt: json['prompt'],
      generationTime: json['generationTime'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'style': style,
      'prompt': prompt,
      'generationTime': generationTime,
    };
  }
}

class EmotionMetadata {
  final bool faceDetected;
  final int faceCount;
  final String imageQuality;
  final double processingTime;
  final String apiVersion;

  EmotionMetadata({
    required this.faceDetected,
    required this.faceCount,
    required this.imageQuality,
    required this.processingTime,
    required this.apiVersion,
  });

  factory EmotionMetadata.fromJson(Map<String, dynamic> json) {
    return EmotionMetadata(
      faceDetected: json['faceDetected'],
      faceCount: json['faceCount'],
      imageQuality: json['imageQuality'],
      processingTime: json['processingTime'].toDouble(),
      apiVersion: json['apiVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faceDetected': faceDetected,
      'faceCount': faceCount,
      'imageQuality': imageQuality,
      'processingTime': processingTime,
      'apiVersion': apiVersion,
    };
  }
}

class EmotionSharing {
  final bool isShared;
  final List<SharedWith> sharedWith;
  final DateTime? sharedAt;

  EmotionSharing({
    required this.isShared,
    required this.sharedWith,
    this.sharedAt,
  });

  factory EmotionSharing.fromJson(Map<String, dynamic> json) {
    return EmotionSharing(
      isShared: json['isShared'] ?? false,
      sharedWith: (json['sharedWith'] as List<dynamic>?)
          ?.map((e) => SharedWith.fromJson(e))
          .toList() ?? [],
      sharedAt: json['sharedAt'] != null ? DateTime.parse(json['sharedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isShared': isShared,
      'sharedWith': sharedWith.map((e) => e.toJson()).toList(),
      'sharedAt': sharedAt?.toIso8601String(),
    };
  }
}

class SharedWith {
  final User user;
  final String? message;
  final DateTime sharedAt;

  SharedWith({
    required this.user,
    this.message,
    required this.sharedAt,
  });

  factory SharedWith.fromJson(Map<String, dynamic> json) {
    return SharedWith(
      user: User.fromJson(json['user']),
      message: json['message'],
      sharedAt: DateTime.parse(json['sharedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'message': message,
      'sharedAt': sharedAt.toIso8601String(),
    };
  }
}

class EmotionReaction {
  final User user;
  final String reaction;
  final DateTime reactedAt;

  EmotionReaction({
    required this.user,
    required this.reaction,
    required this.reactedAt,
  });

  factory EmotionReaction.fromJson(Map<String, dynamic> json) {
    return EmotionReaction(
      user: User.fromJson(json['user']),
      reaction: json['reaction'],
      reactedAt: DateTime.parse(json['reactedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'reaction': reaction,
      'reactedAt': reactedAt.toIso8601String(),
    };
  }
}