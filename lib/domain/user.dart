enum Role { admin, user, guest }

class User {
  final String email;
  final String password;
  final String username;
  final Role role;

  User({
    required this.email,
    required this.password,
    required this.username,
    required this.role,
  });
}
