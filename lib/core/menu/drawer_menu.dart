import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/core/menu/menu_item.dart';

class DrawerMenu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scafoldKey;

  const DrawerMenu({super.key, required this.scafoldKey});

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
