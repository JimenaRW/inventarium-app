import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventarium/data/auth_repository.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final authProvider = StreamProvider<User?>(
  (ref) => _firebaseAuth.authStateChanges(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
