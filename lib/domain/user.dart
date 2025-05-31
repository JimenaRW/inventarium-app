import 'package:inventarium/domain/role.dart';

enum UserStatus { active, inactive }

class User {
  final String id;
  final String email;
  final UserRole role;
  String estado;

  User({
    required this.id,
    required this.email,
    required this.role,
    String? estado,
  }) : estado = estado ?? UserStatus.active.name;

  // Métodos fromJson/toJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.viewer,
      ),
      estado: json['status'] ?? UserStatus.active.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role.toString().split('.').last, 'status': estado};
  }

  User copyWith({String? id, String? email, UserRole? role, String? estado}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      estado: estado ?? this.estado,
    );
  }
}
