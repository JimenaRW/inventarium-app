class User {
  String? uid;
  String? email;
  String? role;

  User({this.uid, this.email, this.role});

  factory User.fromFirebase(User user) {
    return User(uid: user.uid, email: user.email);
  }
}
