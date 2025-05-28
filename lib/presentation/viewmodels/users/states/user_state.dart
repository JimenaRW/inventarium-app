
import 'package:inventarium/domain/user.dart';

class UserState {
  final List<User> users;
  final bool loading;
  final bool updating;
  final String? error;
  final User? user;

  UserState({
    required this.users,
    required this.loading,
    required this.updating,
    this.error,
    this.user
  });

  factory UserState.initial() {
    return UserState(
      users: [],
      loading: false,
      updating: false,
    );
  }

  UserState copyWith({
    List<User>? users,
    bool? loading,
    bool? updating,
    String? error,
    User? user,
  }) {
    return UserState(
      users: users ?? this.users,
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}