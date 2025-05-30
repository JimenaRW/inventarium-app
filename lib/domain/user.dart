import 'package:inventarium/domain/role.dart';

class User {
  final String id;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.role,
  });

  // Métodos fromJson/toJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.viewer,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.toString().split('.').last,
    };
  }

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
  
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
