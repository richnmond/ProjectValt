// lib/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? bio;
  final String role;
  final bool isEmailVerified;
  final Map<String, dynamic> settings;
  final int storageUsed;
  final int storageLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.bio,
    required this.role,
    required this.isEmailVerified,
    required this.settings,
    required this.storageUsed,
    required this.storageLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      bio: json['bio'],
      role: json['role'] ?? 'user',
      isEmailVerified: json['isEmailVerified'] ?? false,
      settings: json['settings'] ?? {},
      storageUsed: json['storageUsed'] ?? 0,
      storageLimit: json['storageLimit'] ?? 1073741824,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'bio': bio,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'settings': settings,
      'storageUsed': storageUsed,
      'storageLimit': storageLimit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    String? bio,
    String? role,
    bool? isEmailVerified,
    Map<String, dynamic>? settings,
    int? storageUsed,
    int? storageLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      settings: settings ?? this.settings,
      storageUsed: storageUsed ?? this.storageUsed,
      storageLimit: storageLimit ?? this.storageLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}