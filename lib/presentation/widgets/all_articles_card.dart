import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/total_articles_provider.dart';
import 'package:inventarium/presentation/widgets/inventory_card.dart';

class AllArticlesCard extends ConsumerWidget {
  const AllArticlesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allArticlesState = ref.watch(allArticlesProvider);

    return allArticlesState.when(
      data:
          (total) => InventoryCard(
            title: "Total de artículos",
            count: total,
            color: Colors.lightBlue.shade500,
          ),
      loading:
          () => const InventoryCard(
            title: "Total de artículos",
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
