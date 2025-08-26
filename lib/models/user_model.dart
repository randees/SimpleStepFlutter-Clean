class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final List<String>? healthGoals;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.healthGoals,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      heightCm: json['height_cm']?.toDouble(),
      weightKg: json['weight_kg']?.toDouble(),
      activityLevel: json['activity_level'] as String?,
      healthGoals: json['health_goals'] != null
          ? List<String>.from(json['health_goals'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'activity_level': activityLevel,
      'health_goals': healthGoals,
    };
  }

  String get friendlyName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    // Extract name from email (before @)
    final emailName = email.split('@')[0];
    // Capitalize first letter and replace dots/underscores with spaces
    return emailName
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word,
        )
        .join(' ');
  }
}
