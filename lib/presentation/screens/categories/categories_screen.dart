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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesNotifierProvider.notifier).clearSearch();
      ref.read(categoriesNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    ref.read(categoriesNotifierProvider.notifier).clearSearch();
    ref.read(categoriesNotifierProvider.notifier).loadCategories();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesNotifierProvider);
    final notifier = ref.read(categoriesNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),

      body: Column(
        children: [
          Text(
            'ELIJA LA OPCIÓN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.add_circle_outline,
                label: 'CREAR\nCATEGORÍA',
                iconSize: 50,
                onTap: () async {
                  await context.push('/categories/create');
                  _searchController.clear();
                  ref.read(categoriesNotifierProvider.notifier).clearSearch();
                  ref.read(categoriesNotifierProvider.notifier).loadCategories();
                },
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Padding(
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
                          ref.read(categoriesNotifierProvider.notifier).clearSearch();
                          notifier.loadCategories();
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => notifier.searchCategories(value),
                  ),
                ),
              ),
              SizedBox(width: 8),
              _ActionButton(
                icon: Icons.delete,
                label: 'BORRAR\nCATEGORÍA',
                onTap: () => context.push(''),
                fontSize: 10,
                iconSize: 25,
              ),
              SizedBox(width: 8), // Espacio entre botones
            ],
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
                      return ListTile(
                        title: Text(category.descripcion),
                        onTap:
                            () => _showCategoryDetails(
                              context,
                              category
                                  .id, // Asegúrate de que tu modelo `Category` tenga un `id`
                              category.descripcion,
                            ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double? fontSize;
  final double? iconSize;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.fontSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: iconSize ?? 20, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize ?? 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void _showCategoryDetails(
  BuildContext context,
  String categoryId,
  String currentDescription,
) {
  final TextEditingController _editController = TextEditingController(
    text: currentDescription,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Necesario para el ajuste del teclado
    builder: (BuildContext bc) {
      return Consumer(
        builder: (context, ref, _) {
          final notifier = ref.read(categoriesNotifierProvider.notifier);
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
          mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Editar Categoría',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _editController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la categoría',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final newDescription = _editController.text.trim();
                          if (newDescription.isNotEmpty) {
                            notifier.updateCategory(
                              categoryId, 
                              newDescription,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}