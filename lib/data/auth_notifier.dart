import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/auth_repository.dart';
import 'package:inventarium/data/user_repository.dart';
import 'package:inventarium/domain/user.dart' as user;
import 'package:inventarium/presentation/viewmodels/article/states/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  String? _userEmail;

  AuthNotifier(this._authRepository) : super(AuthState.init);

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = AuthState.loading;
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      _userEmail = email;
      state = AuthState.authenticated;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    state = AuthState.loading;
    try {
      await _authRepository.registerWithEmail(email, password);
      state = AuthState.authenticated;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading;
    try {
      await _authRepository.signOut();
      _userEmail = null;
      state = AuthState.init;
    } catch (e) {
      state = AuthState.unauthenticated;
    }
  }

  final UserRepository _userRepository = UserRepository();

  Future<user.User?> getCurrentUser() async {
    return await _userRepository.getCurrentUser();
  }

  String? getUserEmail() {
    return _userEmail;
  }

  void reset() {
    state = AuthState.init;
  }
}
