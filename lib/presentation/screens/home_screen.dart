import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/core/menu/drawer_menu.dart';
import 'package:inventarium/data/low_stock_provider.dart';
import 'package:inventarium/data/navigation_provider.dart';
import 'package:inventarium/data/no_stock_provider.dart';
import 'package:inventarium/data/total_articles_provider.dart';
import 'package:inventarium/presentation/widgets/all_articles_card.dart';
import 'package:inventarium/presentation/widgets/category_chart.dart';
import 'package:inventarium/presentation/widgets/category_list.dart';
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
  final _searchController = TextEditingController();

  // Simulación de los datos del gráfico
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
    // Los datos de las categorías se simulan, no necesitan carga asíncrona por ahora
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _reloadData();
  }

  @override
  void didPushNext() {
    // Otra pantalla fue pushed encima de la Home.
  }

  @override
  void didPop() {
    // La pantalla de Home hizo pop (si alguna vez se pusheara directamente).
  }

  @override
  void didPush() {
    _reloadData();
  }

  Future<void> _reloadData() async {
    await ref.read(noStockProvider.notifier).build();
    await ref.read(lowStockProvider.notifier).build();
    await ref.read(totalArticlesProvider.notifier).build();
    // Los datos de las categorías se simulan, no necesitan recarga por ahora
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
      appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda si es necesario
            },
          ),
        ],
      ),
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
              const SizedBox(height: 20),
              const Text(
                "Top 5 Categorías con Más Artículos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CategoryChart(topCategories: topCategories),
              const SizedBox(height: 10),
              CategoryList(topCategories: topCategories),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
