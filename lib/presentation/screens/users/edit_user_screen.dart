import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/domain/user.dart';
import 'package:inventarium/presentation/viewmodels/users/provider.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  static const name = 'edit_user_screen';
  final User user;
  const EditUserScreen({super.key, required this.user});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  late UserRole selectedRole;
  late String selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.user.role;
    selectedStatus = widget.user.status;
  }

  Future<void> _confirmAndUpdate() async {
    if (selectedRole == widget.user.role &&
        selectedStatus == widget.user.status) {
      Navigator.pop(context, false);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar cambios'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedRole != widget.user.role)
                  Text('• Cambiar rol a: ${selectedRole.name}'),
                if (selectedStatus != widget.user.status)
                  Text(
                    '• Cambiar estado a ${selectedStatus == 'active' ? 'Activo' : 'Inactivo'}',
                  ),
                const SizedBox(height: 10),
                const Text('¿Confirmas los cambios?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);

    try {
      if (selectedRole != widget.user.role) {
        await ref
            .read(userNotifierProvider.notifier)
            .updateUserRole(widget.user.id, selectedRole);
      }

      if (selectedStatus != widget.user.status) {
        await ref
            .read(userNotifierProvider.notifier)
            .updateUserStatus(widget.user.id, selectedStatus);
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email: ${widget.user.email}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            const Text(
              "Rol:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              value: selectedRole,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              items:
                  UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(
                        role.name.toUpperCase(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
              onChanged:
                  _isUpdating
                      ? null
                      : (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
            ),

            const SizedBox(height: 20),

            const Text(
              "Estado:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Activo'),
                  value: 'active',
                  groupValue: selectedStatus,
                  onChanged:
                      _isUpdating
                          ? null
                          : (value) {
                            setState(() => selectedStatus = value!);
                          },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile<String>(
                  title: const Text('Inactivo'),
                  value: 'inactive',
                  groupValue: selectedStatus,
                  onChanged:
                      _isUpdating
                          ? null
                          : (value) {
                            setState(() => selectedStatus = value!);
                          },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _confirmAndUpdate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child:
                    _isUpdating
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                        : const Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
