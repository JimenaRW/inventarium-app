import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventarium/data/user_repository.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/domain/user.dart' as userdomain;

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
      } else if (userCredential.user != null &&
          userCredential.user!.uid.isNotEmpty) {
        var userRepository = UserRepository();
        var getUserData = await userRepository.getUserById(
          userCredential.user!.uid,
        );

        if (getUserData != null &&
            getUserData.status != userdomain.UserStatus.active.name) {
          await _firebaseAuth.signOut();

          throw FirebaseAuthException(
            code: 'invalid-status',
            message: 'El usuario fue dado de baja.',
          );
        } else if (getUserData != null &&
            getUserData.role == UserRole.initial) {
          await _firebaseAuth.signOut();

          throw FirebaseAuthException(
            code: 'invalid-role',
            message: 'Aún no fue autorizado a visitar inventarium.',
          );
        }
      }
    } catch (e) {
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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': email,
            'role': UserRole.initial,
            'id': userCredential.user?.uid,
            'status': userdomain.UserStatus.active.name,
          });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
