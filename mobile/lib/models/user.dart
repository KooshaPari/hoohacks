class User {
  final String id;
  final String name;
  final String email;
  final ProfileSettings profileSettings;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileSettings,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileSettings: ProfileSettings.fromJson(json['profileSettings'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'profileSettings': profileSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProfileSettings {
  final String theme;
  final bool notificationsEnabled;
  final HealthMetricsToTrack healthMetricsToTrack;

  ProfileSettings({
    required this.theme,
    required this.notificationsEnabled,
    required this.healthMetricsToTrack,
  });

  factory ProfileSettings.fromJson(Map<String, dynamic> json) {
    return ProfileSettings(
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      healthMetricsToTrack:
          HealthMetricsToTrack.fromJson(json['healthMetricsToTrack'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'healthMetricsToTrack': healthMetricsToTrack.toJson(),
    };
  }
}

class HealthMetricsToTrack {
  final bool sleep;
  final bool activity;
  final bool heartRate;
  final bool nutrition;

  HealthMetricsToTrack({
    required this.sleep,
    required this.activity,
    required this.heartRate,
    required this.nutrition,
  });

  factory HealthMetricsToTrack.fromJson(Map<String, dynamic> json) {
    return HealthMetricsToTrack(
      sleep: json['sleep'] ?? true,
      activity: json['activity'] ?? true,
      heartRate: json['heartRate'] ?? true,
      nutrition: json['nutrition'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sleep': sleep,
      'activity': activity,
      'heartRate': heartRate,
      'nutrition': nutrition,
    };
  }
}
