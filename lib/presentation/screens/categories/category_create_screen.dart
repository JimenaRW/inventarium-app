import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/screens/category_widget/category_form.dart';

class CategoryCreateScreen extends ConsumerWidget {
  static const String name = 'category_create_screen';
  const CategoryCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva categoría')),
      body: Padding(padding: const EdgeInsets.all(16), child: CategoryForm()),
    );
  }
}
