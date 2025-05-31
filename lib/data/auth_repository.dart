import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user?.sendEmailVerification();

        await _firebaseAuth.signOut();

        throw FirebaseAuthException(
          code: 'invalid-email-verified',
          message:
              'Por favor verifica tu correo electrónico antes de iniciar sesión',
        );
      }
    } catch (e) {
      print('Error de inicio de sesión: ${e}');
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.sendEmailVerification();

      await FirebaseAuth.instance.signOut();

      // 2. Guardar rol en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': email,
            'role': 'viewer', // Asignar rol aquí
            'id': userCredential.user?.uid,
          });

      return userCredential;
    } catch (e) {
      print('Error de registro: ${e}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
