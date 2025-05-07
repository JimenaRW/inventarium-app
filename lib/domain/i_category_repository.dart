import 'package:inventarium/domain/category.dart';

abstract interface class ICategoryRepository {
  Future <List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> searchCategory(String query);
}