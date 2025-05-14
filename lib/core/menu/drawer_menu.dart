import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/core/menu/menu_item.dart';

class DrawerMenu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scafoldKey;

  const DrawerMenu({super.key, required this.scafoldKey});

  @override
  Widget build(BuildContext context) {
    final username = AuthController.currentUser?.username ?? 'Invitado';

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: appMenuItems.length,
              itemBuilder: (context, index) {
                final item = appMenuItems[index];
                return ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(item.route);
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    username,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            subtitle: const Text('Salir del sistema'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Confirmar cierre de sesión'),
                      content: const Text(
                        '¿Estás seguro de que querés cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed:
                              () =>
                                  Navigator.of(context).pop(false), // Cancelar
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed:
                              () =>
                                  Navigator.of(context).pop(true), // Confirmar
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
              );

              // Verificar si el contexto sigue montado antes de proceder
              if (!context.mounted) return;

              // Si el usuario confirma, proceder con el logout
              if (confirmed == true) {
                context.go('/auth/logout'); // Redirige al logout
              }
            },
          ),
        ],
      ),
    );
  }
}
