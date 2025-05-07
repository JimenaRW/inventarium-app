import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/category_repository_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  static const String name = 'categories_screen';
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesNotifierProvider);
    final notifier = ref.read(categoriesNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: Column(
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => context.push('/categories/create'),
          ),
          FloatingActionButton(
            child: const Icon(Icons.mode_edit_outline),
            onPressed: () => context.push('/categories/edit'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar categoría',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    notifier.loadCategories();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => notifier.searchCategories(value),
            ),
          ),
          Expanded(
            child: categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data:
                  (categories) => ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(title: Text(category.descripcion));
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
