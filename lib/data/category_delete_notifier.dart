import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/category_delete_state.dart';

class CategoryDeleteNotifier extends StateNotifier<CategoryDeleteState> {
  final CategoryNotifier repository;

  CategoryDeleteNotifier(this.repository)
    : super(
        CategoryDeleteState(
          isLoading: false,
          success: false,
          errorMessage: null,
        ),
      );

  Future<void> deleteCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await repository.softDeleteById(categoryId);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void resetState() {
    state = CategoryDeleteState(
      isLoading: false,
      success: false,
      errorMessage: null,
    );
  }
}
