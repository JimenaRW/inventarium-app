import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/no_stock_provider.dart';
import 'package:inventarium/presentation/widgets/inventory_card.dart';

class NoStockCard extends ConsumerWidget {
  const NoStockCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noStockState = ref.watch(noStockProvider);

    return noStockState.when(
      data:
          (state) => InventoryCard(
            title: "Artículos sin Stock",
            count: state.articles.length,
            color: Colors.lightBlue.shade100,
          ),
      loading:
          () => const InventoryCard(
            title: "Artículos sin Stock",
            count: 0,
            color: Colors.lightBlue,
          ),
      error:
          (error, stackTrace) => InventoryCard(
            title: "Error al cargar",
            count: 0,
            color: Colors.lightBlue.shade400,
          ),
    );
  }
}
