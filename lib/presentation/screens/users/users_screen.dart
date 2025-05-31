import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/user.dart';
import 'package:inventarium/presentation/screens/users/edit_user_screen.dart';
import 'package:inventarium/presentation/viewmodels/users/provider.dart';
import 'package:inventarium/presentation/viewmodels/users/states/user_state.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'Activo'; // Valor inicial

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadCurrentUser();
      ref.read(userNotifierProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotifierProvider);
    
    final filteredUsers = state.users.where((user) {
      // Filtro por estado
      if (_statusFilter == 'Activo') {
        return user.estado == 'active';
      } else {
        return user.estado == 'inactive';
      }
    }).where((user) {
      // Filtro por búsqueda
      if (_searchController.text.isEmpty) return true;
      return user.email.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          user.role.toString().toLowerCase().contains(
                _searchController.text.toLowerCase(),
              );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Filtro de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar usuarios...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Filtro por estado (simplificado)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'Activo',
                      groupValue: _statusFilter,
                      onChanged: (value) {
                        setState(() => _statusFilter = value!);
                      },
                    ),
                    const Text('Activos'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Inactivo',
                      groupValue: _statusFilter,
                      onChanged: (value) {
                        setState(() => _statusFilter = value!);
                      },
                    ),
                    const Text('Inactivos'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildUserTable(state, filteredUsers)),
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
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Rol')),
        ],
        rows: users.map((user) {
          return DataRow(
            onSelectChanged: (_) {
              final freshUser = state.users.firstWhere(
                (u) => u.id == user.id,
                orElse: () => user,
              );
              _showUserDetails(context, user, ref);
            },
            cells: [
              DataCell(Text(user.email)),
              DataCell(Text(user.role.toString().split('.').last)),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalles del Usuario',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Rol', user.role.toString().split('.').last),
                _buildDetailRow(
                  'Estado',
                  user.estado == 'active' ? 'Activo' : 'Inactivo',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserScreen(user: user),
                          ),
                        );
                        if (updated == true) {
                          ref.read(userNotifierProvider.notifier).loadUsers();
                        }
                      },
                      child: const Text('Editar'),
                    ),
                    if(user.estado== 'active')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Eliminar usuario?'),
                            content: const Text(
                              '¿Seguro que querés eliminar este usuario?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => {
                                  ref.read(userNotifierProvider.notifier).loadUsers(),
                                  ref.read(userNotifierProvider.notifier).reset(),
                                  Navigator.pop(ctx, true),
                                },
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref
                              .read(userNotifierProvider.notifier)
                              .softDeleteUserById(user.id);
                          ref.read(userNotifierProvider.notifier).loadUsers();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Usuario eliminado")),
                          );
                        }
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}