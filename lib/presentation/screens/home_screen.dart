import 'package:flutter/material.dart';
import 'package:inventarium/core/menu/drawer_menu.dart';

class HomeScreen extends StatelessWidget {
  static const String name = 'home_screen';
  final scafoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafoldKey,
      appBar: AppBar(
        title: const Text(name),
      ),
      drawer: DrawerMenu(scafoldKey: scafoldKey),
    );
  }
}
