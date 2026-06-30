class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'email': email, 'photoUrl': photoUrl};
  }

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }
}

class OrigamiModel {
  const OrigamiModel({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.minutes,
    required this.paperSize,
    required this.description,
    required this.colorHex,
    required this.imageKey,
    required this.isFavorite,
  });

  final int id;
  final String title;
  final String category;
  final int difficulty;
  final int minutes;
  final String paperSize;
  final String description;
  final String colorHex;
  final String imageKey;
  final bool isFavorite;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'minutes': minutes,
      'paperSize': paperSize,
      'description': description,
      'colorHex': colorHex,
      'imageKey': imageKey,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory OrigamiModel.fromMap(Map<String, Object?> map) {
    return OrigamiModel(
      id: map['id'] as int,
      title: map['title'] as String,
      category: map['category'] as String,
      difficulty: map['difficulty'] as int,
      minutes: map['minutes'] as int,
      paperSize: map['paperSize'] as String,
      description: map['description'] as String,
      colorHex: map['colorHex'] as String,
      imageKey: map['imageKey'] as String,
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }

  OrigamiModel copyWith({bool? isFavorite}) {
    return OrigamiModel(
      id: id,
      title: title,
      category: category,
      difficulty: difficulty,
      minutes: minutes,
      paperSize: paperSize,
      description: description,
      colorHex: colorHex,
      imageKey: imageKey,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class OrigamiStep {
  const OrigamiStep({
    required this.id,
    required this.modelId,
    required this.stepOrder,
    required this.title,
    required this.instruction,
    required this.tip,
    required this.seconds,
    required this.imageKey,
  });

  final int id;
  final int modelId;
  final int stepOrder;
  final String title;
  final String instruction;
  final String tip;
  final int seconds;
  final String imageKey;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'modelId': modelId,
      'stepOrder': stepOrder,
      'title': title,
      'instruction': instruction,
      'tip': tip,
      'seconds': seconds,
      'imageKey': imageKey,
    };
  }

  factory OrigamiStep.fromMap(Map<String, Object?> map) {
    return OrigamiStep(
      id: map['id'] as int,
      modelId: map['modelId'] as int,
      stepOrder: map['stepOrder'] as int,
      title: map['title'] as String,
      instruction: map['instruction'] as String,
      tip: map['tip'] as String,
      seconds: map['seconds'] as int,
      imageKey: (map['imageKey'] as String?) ?? '',
    );
  }
}

class CompletedStep {
  const CompletedStep({
    required this.modelId,
    required this.stepId,
    required this.completedAt,
  });

  final int modelId;
  final int stepId;
  final DateTime completedAt;

  Map<String, Object?> toMap() {
    return {
      'modelId': modelId,
      'stepId': stepId,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory CompletedStep.fromMap(Map<String, Object?> map) {
    return CompletedStep(
      modelId: map['modelId'] as int,
      stepId: map['stepId'] as int,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }
}

class AchievementEntry {
  const AchievementEntry({
    this.id,
    required this.modelId,
    required this.modelTitle,
    required this.note,
    required this.rating,
    required this.completedAt,
    required this.minutesSpent,
    this.photoPath,
  });

  final int? id;
  final int modelId;
  final String modelTitle;
  final String note;
  final int rating;
  final DateTime completedAt;
  final int minutesSpent;
  final String? photoPath;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'modelId': modelId,
      'modelTitle': modelTitle,
      'note': note,
      'rating': rating,
      'completedAt': completedAt.toIso8601String(),
      'minutesSpent': minutesSpent,
      'photoPath': photoPath,
    };
  }

  factory AchievementEntry.fromMap(Map<String, Object?> map) {
    return AchievementEntry(
      id: map['id'] as int,
      modelId: map['modelId'] as int,
      modelTitle: map['modelTitle'] as String,
      note: map['note'] as String,
      rating: map['rating'] as int,
      completedAt: DateTime.parse(map['completedAt'] as String),
      minutesSpent: map['minutesSpent'] as int,
      photoPath: map['photoPath'] as String?,
    );
  }

  AchievementEntry copyWith({
    int? id,
    int? modelId,
    String? modelTitle,
    String? note,
    int? rating,
    DateTime? completedAt,
    int? minutesSpent,
    String? photoPath,
  }) {
    return AchievementEntry(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      modelTitle: modelTitle ?? this.modelTitle,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      completedAt: completedAt ?? this.completedAt,
      minutesSpent: minutesSpent ?? this.minutesSpent,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

class BadgeAward {
  const BadgeAward({
    required this.code,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  final String code;
  final String title;
  final String description;
  final bool unlocked;

  BadgeAward copyWith({bool? unlocked}) {
    return BadgeAward(
      code: code,
      title: title,
      description: description,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

class CompletionRuleResult {
  const CompletionRuleResult({required this.allowed, required this.message});

  final bool allowed;
  final String message;
}
