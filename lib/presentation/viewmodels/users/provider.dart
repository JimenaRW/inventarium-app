import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/user_repository_provider.dart';
import 'notifiers/user_notifier.dart';
import 'states/user_state.dart';


final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final notifier = UserNotifier(
ref.read
(userRepositoryProvider));
// Usar Future.microtask para posponer la ejecución después del build
  Future.microtask(() => notifier.loadCurrentUser()); 
  return notifier;
}); 


