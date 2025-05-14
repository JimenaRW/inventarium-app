import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/core/menu/menu_item.dart';
import 'package:inventarium/data/auth_notifier_provider.dart';
import 'package:inventarium/data/auth_repository_provider.dart';

class DrawerMenu extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DrawerMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children:
                  appMenuItems.map((item) => MenuTile(item: item)).toList(),
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
              ],
            ),
          ),
          MenuTile(item: logoutMenuItem),
        ],
      ),
    );
  }
}
