import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/core/menu/menu_item.dart';
import 'package:inventarium/data/auth_notifier_provider.dart';
import 'package:inventarium/domain/user.dart' as user;

class DrawerMenu extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DrawerMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authStateProvider.notifier);

    return FutureBuilder<user.User?>(
      future: authNotifier.getCurrentUser(),
      builder: (context, snapshot) {
        final currentUser = snapshot.data;

        // Filtrar ítems basados en el rol del usuario
        final visibleMenuItems = appMenuItems.where((item) {
          return item.allowedRoles.contains(currentUser?.role);
        }).toList();

        return Drawer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: visibleMenuItems.map((item) => MenuTile(item: item)).toList(),
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
                        authNotifier.getUserEmail() ?? 'Invitado',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (currentUser != null) // Mostrar rol si hay usuario
                      Chip(
                        label: Text(
                          currentUser.role.toString().split('.').last,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              MenuTile(item: logoutMenuItem),
            ],
          ),
        );
      },
    );
  }
}