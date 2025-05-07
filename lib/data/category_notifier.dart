// category_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/category.dart';

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
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

  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      await loadCategories();
      return;
    }

    state = const AsyncValue.loading();
    try {
      final results = await _repository.searchCategory(query);
      state = AsyncValue.data(results.whereType<Category>().toList());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
