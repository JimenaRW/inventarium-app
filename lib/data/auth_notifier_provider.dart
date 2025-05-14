import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/auth_notifier.dart';
import 'package:inventarium/data/auth_repository.dart';
import 'package:inventarium/data/auth_repository_provider.dart';
import 'package:inventarium/domain/user.dart';
import 'package:inventarium/presentation/viewmodels/article/states/auth_state.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
