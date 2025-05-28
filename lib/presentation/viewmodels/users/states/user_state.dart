
import 'package:inventarium/domain/user.dart';

class UserState {
  final List<User> users;
  final bool loading;
  final bool updating;
  final String? error;
  final User? currentUser;


  UserState({
    required this.users,
    required this.loading,
    required this.updating,
    required this.currentUser,
    this.error,
  });

  factory UserState.initial() {
    return UserState(
      users: [],
      loading: false,
      updating: false,
      currentUser: null,
    );
  }

  UserState copyWith({
    List<User>? users,
    bool? loading,
    bool? updating,
    String? error,
  User? currentUser,
  }) {
    return UserState(
      users: users ?? this.users,
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      currentUser: this.currentUser,
      error: error ?? this.error,
    );
  }
}