import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/auth_repository.dart';
import 'package:inventarium/domain/user.dart';
import 'package:inventarium/presentation/viewmodels/article/states/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.unauthenticated);

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = AuthState.loading;
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.unauthenticated;
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading;
    try {
      await _authRepository.signOut();
      state = AuthState.unauthenticated;
    } catch (e) {
      // Manejar error
    }
  }
}
