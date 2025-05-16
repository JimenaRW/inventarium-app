import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/core/menu/drawer_menu.dart';
import 'package:inventarium/data/no_stock_provider.dart';
import 'package:inventarium/presentation/widgets/category_chart.dart';
import 'package:inventarium/presentation/widgets/category_list.dart';
import 'package:inventarium/presentation/widgets/no_stock_card.dart'; // Importa NoStockCard

class HomeScreen extends ConsumerStatefulWidget {
  static const String name = 'home_screen';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  // Simulación de los conteos (estos ya no se usarán directamente)
  final int bajoStockCount = 30;
  final int totalArticulosCount = 125;

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
    // Aquí deberías llamar a tu función para obtener los datos reales de las categorías:
    // topCategories = ref.read(tuProveedorDeDatos).getTop5CategoriesWithCounts();
    // Dispara la carga inicial de los datos de artículos sin stock
    ref.read(noStockProvider.notifier).loadArticlesWithNoStock();
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
                  NoStockCard(), // Usamos el nuevo widget NoStockCard
                  // Aquí irán los otros ConsumerWidgets para las otras cards
                  // LowStockCard(),
                  // TotalArticlesCard(),
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
