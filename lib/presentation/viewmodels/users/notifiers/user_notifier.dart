import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/user_repository.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/presentation/viewmodels/users/states/user_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _userRepository;

  UserNotifier(this._userRepository) : super(UserState.initial());

  Future<void> loadCurrentUser() async {
    state = state.copyWith(loading: true);
    try {
      final user = await _userRepository.getCurrentUser();
      state = state.copyWith(currentUser: user, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> loadUsers() async {
    try {
      state = state.copyWith(loading: true);
      final users = await _userRepository.getAllUsers();
      state = state.copyWith(users: users, loading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    state = state.copyWith(updating: true);
    try {
      await _userRepository.updateUserRole(userId, newRole);
      state = state.copyWith(
        users:
            state.users.map((user) {
              if (user.id == userId) {
                return user.copyWith(role: newRole);
              }
              return user;
            }).toList(),
        updating: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), updating: false);
    }
  }
}
