import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/presentation/viewmodels/users/provider.dart';
import 'package:inventarium/presentation/widgets/category_list_card.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  static const String name = 'categories_screen';
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();
  CategoryStatus? _selectedStatus;

  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoriesNotifierProvider.notifier)
          .loadCategoriesByStatus(_selectedStatus);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.clear();
    });

    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadCurrentUser();
    });
  }

  @override
  void dispose() {
    try {
      ref.invalidate(categoriesNotifierProvider);
      // ignore: empty_catches
    } catch (e) {}
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesNotifierProvider);
    final userState = ref.read(userNotifierProvider);
    final currentRol = userState.user?.role;
    final showCreateButton =
        currentRol == UserRole.admin || currentRol == UserRole.editor;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),

      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (showCreateButton)
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
                  Text('Filtrar por estado:'),
                  Row(
                    children: [
                      Radio<CategoryStatus?>(
                        value: null,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            ref
                                .read(categoriesNotifierProvider.notifier)
                                .loadCategoriesByStatus(value);
                          });
                        },
                      ),
                      const Text('Todos'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<CategoryStatus?>(
                        value: CategoryStatus.active,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            ref
                                .read(categoriesNotifierProvider.notifier)
                                .loadCategoriesByStatus(value);
                          });
                        },
                      ),
                      const Text('Activos'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<CategoryStatus?>(
                        value: CategoryStatus.inactive,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            ref
                                .read(categoriesNotifierProvider.notifier)
                                .loadCategoriesByStatus(value);
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
                    decoration: InputDecoration(
                      labelText: 'Buscar categoría',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(categoriesNotifierProvider.notifier)
                              .searchCategories('');
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    controller: _searchController,
                    onChanged:
                        (value) => ref
                            .read(categoriesNotifierProvider.notifier)
                            .searchCategories(value),
                  ),
                ),
              ),

              SizedBox(width: 8),
            ],
          ),

          Expanded(
            child: categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data:
                  (categories) => ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryListCard(
                        category: category,
                        isSelected: _selectedCategory?.id == category.id,
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
    // ignore: unused_element_parameter
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
  final userState = ref.read(userNotifierProvider);
  final currentRol = userState.user?.role;
  final enableBotton =
      currentRol == UserRole.admin || currentRol == UserRole.editor;

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
                  'Detalles de la categoría',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Descripción', category.description),
                _buildDetailRow(
                  'Estado',
                  category.status == CategoryStatus.active.name
                      ? 'Activo'
                      : 'Inactivo',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (enableBotton)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/categories/edit/${category.id}');
                        },
                        child: const Text('Editar'),
                      ),
                    if (enableBotton &&
                        category.status == CategoryStatus.active.name)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            softWrap: true,
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    ),
  );
}
