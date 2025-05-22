import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/category.dart';

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;
  String _searchQuery = '';
  bool _mounted = true; // Agrega una bandera para rastrear el estado del widget

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  @override
  void dispose() {
    _mounted =
        false; // Establece la bandera a false cuando se elimina el notifier
    super.dispose();
  }

  void resetSearch() {
    if (!_mounted) return; // Verifica mounted
    state = state.whenData((_) => []);
    loadCategories();
  }

  void clearSearch() {
    if (!_mounted) return; // Verifica mounted
    _searchQuery = '';
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (!_mounted) return; // Verifica mounted
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
      if (!_mounted)
        return; // Verifica mounted después de la operación asíncrona
      state = AsyncValue.data(
        _searchQuery.isEmpty
            ? categories
            : categories
                .where(
                  (x) => x.descripcion.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList(),
      );
    } catch (e) {
      if (!_mounted) return; // Verifica mounted en caso de error
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addCategory(String description) async {
    if (!_mounted) return;
    try {
      final newCategory = Category(id: "", descripcion: description);
      if (!_mounted) return;
      state = AsyncValue.data([...?state.value, newCategory]);
      await _repository.addCategory(newCategory);
    } catch (e) {
      rethrow;
    }
  }

  void searchCategories(String query) {
    if (!_mounted) return;
    _searchQuery = query;
    loadCategories();
  }

  Future<void> updateCategory(String categoryId, String newDescription, String newStatus) async {
    try {
      state = const AsyncValue.loading();
      await _repository.updateCategory(
        Category(id: categoryId, descripcion: newDescription, estado: newStatus),
      );
      await loadCategories(); // Forzar recarga
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> loadCategoriesByStatus(CategoryStatus status) async {
    print('Cargando categorías por estado: ${status.name}');
    state = const AsyncLoading();
    try {
      final categories = await _repository.getCategoriesByStatus(status.name);
      print('Categorías obtenidas: ${categories.length}');
      state = AsyncData(categories);
    } catch (e) {
      print('Error al cargar categorías: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> softDeleteById(String id) async {
    try {
      final category = await _repository.getCategoryById(id);

      if (category == null) {
        throw ("La categoría no se encuentra disponible en la base de datos.",);
      }

      if (category.estado == CategoryStatus.inactive.name) {
        throw ("La categoría ya se encuentra inactiva.");
      }

      final softDeleteCategory = category.copyWith(
        estado: CategoryStatus.inactive.name,
      );

      await _repository.deleteCategory(softDeleteCategory);
    } catch (e) {
      rethrow;
    }
  }
}
