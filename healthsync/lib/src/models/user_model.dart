class User {
  final String id;
  final String? name;
  final String email;
  final String? dob;
  final String? authProvider; // 'google', 'apple', etc.
  final Map<String, dynamic>? authProviderData; // Stores additional provider data
  final bool hasHealthkitConsent;
  final bool hasGoogleFitConsent;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    this.name,
    required this.email,
    this.dob,
    this.authProvider,
    this.authProviderData,
    this.hasHealthkitConsent = false,
    this.hasGoogleFitConsent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      dob: json['dob'],
      authProvider: json['authProvider'],
      authProviderData: json['authProviderData'],
      hasHealthkitConsent: json['hasHealthkitConsent'] ?? false,
      hasGoogleFitConsent: json['hasGoogleFitConsent'] ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt']) 
        : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'dob': dob,
      'authProvider': authProvider,
      'authProviderData': authProviderData,
      'hasHealthkitConsent': hasHealthkitConsent,
      'hasGoogleFitConsent': hasGoogleFitConsent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? dob,
    String? authProvider,
    Map<String, dynamic>? authProviderData,
    bool? hasHealthkitConsent,
    bool? hasGoogleFitConsent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      authProvider: authProvider ?? this.authProvider,
      authProviderData: authProviderData ?? this.authProviderData,
      hasHealthkitConsent: hasHealthkitConsent ?? this.hasHealthkitConsent,
      hasGoogleFitConsent: hasGoogleFitConsent ?? this.hasGoogleFitConsent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
