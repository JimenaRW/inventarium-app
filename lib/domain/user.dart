enum Role { admin, user, guest }

class User {
  final String id; //lo tomaríamos la base de datos de Firestore. Es un string
  final String email;
  final String username;
  final Role role;

  User({
    required this.id, //lo tomaríamos la base de datos de Firestore. Es un string
    required this.email,
    required this.username,
    required this.role,
  });
}


//Saqué el password, el profe dijo que no se almacena en el model.
