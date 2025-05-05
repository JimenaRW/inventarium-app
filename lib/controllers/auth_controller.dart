import 'package:inventarium/domain/user.dart';

class AuthController {
  static final List<User> _users = [
    User(
      email: 'user1@example.com',
      password: 'password1',
      username: 'admin',
      role: Role.admin,
    ),
    User(
      email: 'user2@example.com',
      password: 'password2',
      username: 'guest',
      role: Role.guest,
    ),
    User(
      email: 'user3@example.com',
      password: 'password3',
      username: 'user',
      role: Role.user,
    ),
  ];

  static User? currentUser;

  static String register(User newUser, String confirmPassword) {
    // Verificar si el email ya está registrado
    if (_users.any((u) => u.email == newUser.email)) {
      return 'Ya existe un usuario con ese email.';
    }

    // Verificar que las contraseñas coincidan
    if (newUser.password != confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }

    // Si todo es válido, agregar el nuevo usuario
    _users.add(newUser);
    currentUser = newUser;
    return 'Registro exitoso.';
  }

  static bool login(String username, String password) {
    final matches = _users.where(
      (u) => u.username == username && u.password == password,
    );
    if (matches.isNotEmpty) {
      currentUser = matches.first;
      return true;
    }
    return false;
  }

  static void logout() {
    currentUser = null;
  }
}
