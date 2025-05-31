import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/core/menu/drawer_menu.dart';
import 'package:inventarium/data/category_repository_provider.dart';

import 'package:inventarium/data/low_stock_provider.dart';
import 'package:inventarium/data/navigation_provider.dart';
import 'package:inventarium/data/no_stock_provider.dart';
import 'package:inventarium/data/top_categories_provider.dart';
import 'package:inventarium/data/total_articles_provider.dart';
import 'package:inventarium/presentation/widgets/all_articles_card.dart';

import 'package:inventarium/presentation/widgets/category_dashboard.dart';

import 'package:inventarium/presentation/widgets/low_stock_card.dart';
import 'package:inventarium/presentation/widgets/no_stock_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String name = 'home_screen';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  Map<String, int> topCategories = {
    'Electrónica': 50,
    'Ropa': 80,
    'Hogar': 120,
    'Libros': 65,
    'Alimentos': 90,
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await ref.read(noStockProvider.notifier).build();
    await ref.read(lowStockProvider.notifier).build();
    await ref.read(totalArticlesProvider.notifier).build();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void didPopNext() {
    Future.microtask(_reloadData);
  }

  @override
  void didPush() {
    Future.microtask(_reloadData);
  }

  Future<void> _reloadData() async {
    ref.invalidate(noStockProvider);
    ref.invalidate(lowStockProvider);
    ref.invalidate(totalArticlesProvider);
    ref.invalidate(topCategoriesProvider);
    ref.invalidate(categoriesNotifierProvider);
  }

  @override
  void dispose() {
    ref.read(routeObserverProvider).unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(title: const Text("Inicio")),
      drawer: DrawerMenu(scaffoldKey: widget.scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Para revisar...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
                children: const <Widget>[
                  NoStockCard(),
                  LowStockCard(),
                  TotalArticlesCard(),
                ],
              ),
              const SizedBox(height: 10),
              CategoryDashboard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
