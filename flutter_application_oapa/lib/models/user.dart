enum UserRole {
  visitor,
  adopter,
  shelter,
  admin,
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.adopter,
      ),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

