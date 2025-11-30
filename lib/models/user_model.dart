// lib/models/user_model.dart
class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final int rewardPoints;

  AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    this.rewardPoints = 0,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      rewardPoints: (data['rewardPoints'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'rewardPoints': rewardPoints,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    int? rewardPoints,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }
}