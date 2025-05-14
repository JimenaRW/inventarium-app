import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/auth_notifier_provider.dart';

class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool isLogout;

  const MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.isLogout = false,
  });
}

const List<MenuItem> appMenuItems = [
  MenuItem(
    title: "Inicio",
    subtitle: 'Inicio',
    icon: Icons.home_outlined,
    route: '/',
  ),
  MenuItem(
    title: 'Artículos',
    subtitle: 'Añadir artículos',
    icon: Icons.inventory_2_outlined,
    route: '/articles',
  ),
  MenuItem(
    title: 'Categorías',
    subtitle: 'Añadir categorías',
    icon: Icons.list_alt_outlined,
    route: '/categories',
  ),
];

// Este item lo podés seguir teniendo si querés usarlo manualmente
const logoutMenuItem = MenuItem(
  title: 'Cerrar sesión',
  subtitle: 'Salir del sistema',
  icon: Icons.logout,
  route: '/auth/login',
  isLogout: true,
);

class MenuTile extends ConsumerWidget {
  final MenuItem item;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const MenuTile({
    super.key,
    required this.item,
    this.iconColor,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(item.icon, color: iconColor),
      title: Text(item.title, style: titleStyle),
      subtitle: Text(item.subtitle, style: subtitleStyle),
      trailing: item.isLogout ? null : const Icon(Icons.chevron_right),
      onTap: () {
        if (item.isLogout) {
          ref.read(authStateProvider.notifier).signOut();
          context.go(item.route); // Redirige al login
        } else {
          context.push(item.route);
        }
      },
    );
  }
}
