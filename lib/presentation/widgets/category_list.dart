import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final Map<String, int> topCategories;
  final List<Color> barColors;

  const CategoryList({
    super.key,
    required this.topCategories,
    this.barColors = const [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ],
  });

  @override
  Widget build(BuildContext context) {
    if (topCategories.isEmpty) {
      return const Center(child: Text("No hay categorías para mostrar."));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topCategories.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final category = topCategories.keys.elementAt(index);
        final count = topCategories[category];
        final color = barColors[index % barColors.length];
        return ListTile(
          leading: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
          ),
          title: Text(category),
          trailing: Text('$count artículos'),
        );
      },
    );
  }
}
