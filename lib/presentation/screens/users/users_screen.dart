import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/domain/user.dart';
import 'package:inventarium/presentation/viewmodels/users/provider.dart';
import 'package:inventarium/presentation/viewmodels/users/states/user_state.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadUsers();
    });
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final state = ref.read(userNotifierProvider);
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredUsers = state.users.where((user) {
        return user.email.toLowerCase().contains(query) ||
               user.role.toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotifierProvider);
    final displayUsers = _searchController.text.isEmpty ? state.users : _filteredUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
      ),
      body: Column(
        children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar usuarios...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    ),
    Expanded(
      child: _buildUserTable(state, displayUsers),
    ),

  ],
      ),
    );
  }

  Widget _buildUserTable(UserState state, List<User> users) {
    if (state.loading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && users.isEmpty) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (users.isEmpty) {
      return const Center(child: Text('No se encontraron usuarios'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Rol')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: users.map((user) {
          return DataRow(
            cells: [
              DataCell(Text(user.email)),
              DataCell(Text(user.role.toString().split('.').last)),
              DataCell(
                Row(
                  children: [
                    if (_canEditUser(state.currentUser, user))
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editUser(user),
                      ),
                    if (_canDeleteUser(state.currentUser, user))
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, user),
                      ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  bool _canEditUser(User? currentUser, User targetUser) {
    return currentUser?.role == UserRole.admin || 
           currentUser?.id == targetUser.id;
  }

  bool _canDeleteUser(User? currentUser, User targetUser) {
    return currentUser?.role == UserRole.admin && 
           currentUser?.id != targetUser.id;
  }

  void _editUser(User user) {
    // Navegar a pantalla de edición
    context.go('/users/edit/${user.id}');
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar al usuario ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
             // ref.read(userNotifierProvider.notifier).deleteUser(user.id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}