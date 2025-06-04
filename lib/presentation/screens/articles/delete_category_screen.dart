import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository_provider.dart';

class DeleteCategoryScreen extends ConsumerWidget {
  final String categoryId;
  static const String name = 'delete_category_screen';

  const DeleteCategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryDeleteNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar Categoría')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de querer eliminar esta categoría?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('ID del artículo: $categoryId'),
            const SizedBox(height: 16),

            if (categoryState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  categoryState.errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      categoryState.isLoading
                          ? null
                          : () async {
                            await ref
                                .read(categoryDeleteNotifierProvider.notifier)
                                .deleteCategory(categoryId);
                            await Future.delayed(const Duration(seconds: 2));
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          },
                  child:
                      categoryState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Eliminar'),
                ),
              ],
            ),

            if (categoryState.success)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Categoría eliminada correctamente.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
