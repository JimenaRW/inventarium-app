import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/auth_notifier_provider.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/presentation/viewmodels/users/provider.dart';


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
    allowedRoles: [UserRole.viewer, UserRole.editor, UserRole.admin]
  ),
  MenuItem(
    title: 'Artículos',
    subtitle: 'Añadir artículos',
    icon: Icons.inventory_2_outlined,
    route: '/articles',
    allowedRoles: [UserRole.viewer, UserRole.editor, UserRole.admin]
  ),
  MenuItem(
    title: 'Categorías',
    subtitle: 'Añadir categorías',
    icon: Icons.list_alt_outlined,
    route: '/categories',
    allowedRoles: [UserRole.viewer, UserRole.editor, UserRole.admin]
  ),
  MenuItem(
    title: 'Gestión de usuarios',
    subtitle: 'Añadir usuarios',
    icon: Icons.list_alt_outlined,
    route: '/users',
    allowedRoles: [UserRole.admin]
  ),


  MenuItem(
    title: 'Stock',
    subtitle: 'Actualizar stock',
    icon: Icons.inventory,
    route: '/stock',
    allowedRoles: [UserRole.admin, UserRole.editor]
  ),
];

// Este item lo podés seguir teniendo si querés usarlo manualmente
const logoutMenuItem = MenuItem(
  title: 'Cerrar sesión',
  subtitle: 'Salir del sistema',
  icon: Icons.logout,
  route: '/auth/login',
  isLogout: true,
  allowedRoles: [UserRole.viewer, UserRole.editor, UserRole.admin]
);


// Widget para obtener el menú filtrado por rol
class RoleFilteredMenu extends ConsumerWidget {
  const RoleFilteredMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    final currentRol = userState.user?.role ?? UserRole.viewer;

    
    // Filtrar items según el rol del usuario
    final visibleItems = appMenuItems.where((item) {
      print('Verificando item: ${item.title} para rol: $currentRol');
      return item.allowedRoles.contains(currentRol) || item.isLogout;
    }).toList();

    return Column(
      children: [
        ...visibleItems.map((item) => MenuTile(item: item)),
        const MenuTile(item: logoutMenuItem), // Logout siempre al final
      ],
    );
  }
}

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
