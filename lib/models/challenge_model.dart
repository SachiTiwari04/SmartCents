// lib/models/challenge_model.dart

class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final bool isCompleted;
  final bool isAccepted;
  final String? dateKey;
  final String? icon;
  final String? difficulty;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    this.isCompleted = false,
    this.isAccepted = false,
    this.dateKey,
    this.icon,
    this.difficulty,
    this.acceptedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'isCompleted': isCompleted,
      'isAccepted': isAccepted,
      'dateKey': dateKey,
      'icon': icon,
      'difficulty': difficulty,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      points: map['points'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      isAccepted: map['isAccepted'] ?? false,
      dateKey: map['dateKey'],
      icon: map['icon'],
      difficulty: map['difficulty'],
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? points,
    bool? isCompleted,
    bool? isAccepted,
    String? dateKey,
    String? icon,
    String? difficulty,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      isAccepted: isAccepted ?? this.isAccepted,
      dateKey: dateKey ?? this.dateKey,
      icon: icon ?? this.icon,
      difficulty: difficulty ?? this.difficulty,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}