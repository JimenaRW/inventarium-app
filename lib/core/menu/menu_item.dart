import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/auth_notifier_provider.dart';
import 'package:inventarium/domain/role.dart';

class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool isLogout;
  final List<UserRole> allowedRoles;

  const MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.isLogout = false,
    this.allowedRoles = const [UserRole.admin, UserRole.editor, UserRole.viewer],
  });
}

const List<MenuItem> appMenuItems = [
  MenuItem(
    title: "Inicio",
    subtitle: 'Inicio',
    icon: Icons.home_outlined,
    route: '/',
    allowedRoles: [UserRole.admin, UserRole.editor, UserRole.viewer],
  ),
  MenuItem(
    title: 'Artículos',
    subtitle: 'Añadir artículos',
    icon: Icons.inventory_2_outlined,
    route: '/articles',
    allowedRoles: [UserRole.admin, UserRole.editor, UserRole.viewer],
  ),
  MenuItem(
    title: 'Categorías',
    subtitle: 'Añadir categorías',
    icon: Icons.list_alt_outlined,
    route: '/categories',
    allowedRoles: [UserRole.admin, UserRole.editor, UserRole.viewer], 
  ),
  MenuItem(
    title: 'Stock',
    subtitle: 'Actualizar stock',
    icon: Icons.inventory,
    route: '/stock',
    allowedRoles: [UserRole.admin, UserRole.editor],
  ),
  MenuItem(
    title: 'Usuarios',
    subtitle: 'Gestionar usuarios',
    icon: Icons.people_alt_outlined,
    route: '/users',
    allowedRoles: [UserRole.admin],
  ),
  MenuItem(
    title: 'Tema',
    subtitle: 'Cambiar tema',
    icon: Icons.brightness_6_outlined,
    route: '/theme',
  ),
];



const logoutMenuItem = MenuItem(
  title: 'Cerrar sesión',
  subtitle: 'Salir del sistema',
  icon: Icons.logout,
  route: '/auth/login',
  isLogout: true,
  allowedRoles: [UserRole.admin, UserRole.editor, UserRole.viewer], 
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
          
ref.read
(authStateProvider.notifier).signOut();
          context.go(item.route); 
        } else {
          context.push(item.route);
        }
      },
    );
  }
} 

