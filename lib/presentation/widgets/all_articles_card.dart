import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/total_articles_provider.dart';
import 'package:inventarium/presentation/widgets/inventory_card.dart';

class TotalArticlesCard extends ConsumerWidget {
  const TotalArticlesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalArticlesState = ref.watch(totalArticlesProvider);

    return totalArticlesState.when(
      data:
          (total) => InventoryCard(
            title: "Total de Artículos",
            count: total,
            color: Colors.lightBlue.shade500,
          ),
      loading:
          () => const InventoryCard(
            title: "Total de Artículos",
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
