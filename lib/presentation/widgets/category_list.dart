import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final Map<String, int> topCategories;

  const CategoryList({super.key, required this.topCategories});

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
        return ListTile(
          title: Text(category),
          trailing: Text('$count artículos'),
        );
      },
    );
  }
}
