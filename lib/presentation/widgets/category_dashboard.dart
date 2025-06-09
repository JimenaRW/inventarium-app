import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/top_categories_provider.dart';
import 'package:inventarium/presentation/widgets/category_chart.dart';
import 'package:inventarium/presentation/widgets/category_list.dart';

class CategoryDashboard extends ConsumerWidget {
  const CategoryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topCategoriesAsync = ref.watch(topCategoriesProvider);
    const List<Color> chartColors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Top de categorías por cantidad de artículos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: topCategoriesAsync.when(
            data:
                (topCategories) => CategoryChart(
                  topCategories: topCategories,
                  barColors: chartColors,
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Lista de categorías',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          child: topCategoriesAsync.when(
            data:
                (topCategories) => CategoryList(
                  topCategories: topCategories,
                  barColors: chartColors,
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }
}
