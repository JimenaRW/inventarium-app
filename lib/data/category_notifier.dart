// category_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/category.dart';

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;
  String _searchQuery = ''; // Almacena la consulta de búsqueda

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  void resetSearch() {
    state = state.whenData((_) => []); // Limpia la lista temporalmente
    loadCategories(); // Vuelve a cargar la lista completa
  }

  void clearSearch() {
    _searchQuery = '';
    loadCategories(); // Vuelve a cargar la lista completa
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
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
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addCategory(String description) async {
    try {
      final newCategory = Category(id: "", descripcion: description);

      state = AsyncValue.data([...?state.value, newCategory]);

      await _repository.addCategory(newCategory);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      state.whenData(
        (categories) =>
            state = AsyncValue.data(
              categories.where((c) => c.id != id).toList(),
            ),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  void searchCategories(String query) {
    _searchQuery = query;

    loadCategories();
  }

  Future<void> updateCategory(String categoryId, String newDescription) async {
    try {
      state = const AsyncValue.loading();
      Category category = Category(id: categoryId, descripcion: newDescription);
      await _repository.updateCategory(category);
      await loadCategories(); // Recarga la lista después de la actualización
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
