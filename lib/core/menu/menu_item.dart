import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
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
    title: "Login",
    subtitle: 'Login',
    icon: Icons.supervised_user_circle_outlined,
    route: '/auth/login',
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

class MenuTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: iconColor),
      title: Text(item.title, style: titleStyle),
      subtitle: Text(item.subtitle, style: subtitleStyle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(item.route),
    );
  }
}
