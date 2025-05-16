import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/low_stock_provider.dart';
import 'package:inventarium/presentation/widgets/inventory_card.dart';

class LowStockCard extends ConsumerWidget {
  const LowStockCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockState = ref.watch(lowStockProvider);

    return lowStockState.when(
      data:
          (state) => InventoryCard(
            title: "Artículos con Stock Bajo",
            count: state.articles.length,
            color: Colors.lightBlue.shade300, // Puedes elegir otro color
          ),
      loading:
          () => const InventoryCard(
            title: "Artículos con Stock Bajo",
            count: 0,
            color: Colors.grey,
          ),
      error:
          (error, stackTrace) => InventoryCard(
            title: "Error al cargar",
            count: 0,
            color: Colors.orangeAccent,
          ),
    );
  }
}
