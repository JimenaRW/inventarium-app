import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/domain/user.dart';
import 'package:inventarium/presentation/viewmodels/users/provider.dart';
import 'package:inventarium/presentation/viewmodels/users/states/user_state.dart';

class UsersScreen extends ConsumerStatefulWidget{
  const UsersScreen({Key? key}) : super(key: key);

@override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {

 @override
    void initState() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userNotifierProvider.notifier);
      });
    }

  @override
  Widget build(BuildContext context) {
   

    final userState = ref.watch(userNotifierProvider);
    if (userState.loading) {
      ref.read(userNotifierProvider.notifier).loadUsers();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: _buildBody(userState),
      floatingActionButton: userState.currentUser?.role == UserRole.admin
          ? FloatingActionButton(
              onPressed: () => context.go('/users/create'),
              child: const Icon(Icons.add),
              tooltip: 'Crear Usuario',
            )
          : null,
    );
  }

  Widget _buildBody(UserState state) {
    final userState = ref.read(userNotifierProvider);
    // if (state.loading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    // if (state.error != null) {
    //   return Center(child: Text('Error: ${state.error}'));
    // }

    return ListView.builder(
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return ListTile(
          title: Text(user.email),
          subtitle: Text('Rol: ${user.role.toString().split('.').last}'),
          trailing:
              state.currentUser?.role == UserRole.admin &&
                      state.currentUser?.id != user.id
                  ? _buildRoleDropdown(user)
                  : null,
        );
      },
    );
  }

  Widget _buildRoleDropdown(User user) {
    return DropdownButton<UserRole>(
      value: user.role,
      items:
          UserRole.values.map((role) {
            return DropdownMenuItem<UserRole>(
              value: role,
              child: Text(role.toString().split('.').last),
            );
          }).toList(),
      onChanged: (newRole) {
        if (newRole != null) {
          ref
              .read(userNotifierProvider.notifier)
              .updateUserRole(user.id, newRole);
        }
      },
    );
  }
}
