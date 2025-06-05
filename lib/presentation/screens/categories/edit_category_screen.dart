import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/presentation/widgets/edit_category_form.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  static const String name = 'edit_category_screen';
  final String id;

  const EditCategoryScreen({super.key, required this.id});

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesNotifierProvider);
    
    return categoriesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (categories) {
        final category = categories.firstWhere(
          (element) => element.id == widget.id,
          orElse: () => Category(id: '', description: 'Categoría no encontrada'),
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Editar Categoría')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EditCategoryForm(
              categoryId: category.id,
              initialDescription: category.description,
              initialStatus: category.status,
            ),
          ),
        );
      },
    );
  }
}