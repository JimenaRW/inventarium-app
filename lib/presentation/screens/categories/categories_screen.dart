import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/presentation/screens/categories/edit_category_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  static const String name = 'categories_screen';
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();
  CategoryStatus _selectedStatus = CategoryStatus.active;

  Category? _selectedCategory;

  @override
  void dispose() {
    try {
      ref.invalidate(categoriesNotifierProvider);
    } catch (e) {
      // Ignorar la excepción
    }
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
                onTap: () => context.push('/categories/create'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Radio<CategoryStatus>(
                        value: CategoryStatus.active,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            notifier.loadCategoriesByStatus(value);
                          });
                        },
                      ),
                      const Text('Activos'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<CategoryStatus>(
                        value: CategoryStatus.inactive,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            notifier.loadCategoriesByStatus(value);
                          });
                        },
                      ),
                      const Text('Inactivos'),
                    ],
                  ),
                ],
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

                          notifier.loadCategories();
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => notifier.searchCategories(value),
                  ),
                ),
              ),

              // Botones adicionales
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
                        selected: _selectedCategory?.id == category.id,
                        onTap: () {
                          setState(() => _selectedCategory = category);
                          _showCategoryDetails(context, category, ref);
                        },
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
  Category category,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext bc) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Wrap(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detalles de la Categoría',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('ID', category.id),
                _buildDetailRow('Descripción', category.descripcion),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/categories/edit/${category.id}');
                      },
                      child: const Text('Editar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/categories/delete/${category.id}');
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    ),
  );
}
