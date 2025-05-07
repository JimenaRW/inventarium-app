import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/domain/i_category_repository.dart';

class CategoryRepository implements ICategoryRepository {
  final FirebaseFirestore db;

CategoryRepository(this.db) : super();


 
  @override
  Future<void> addCategory(Category category) async {
    try {
      final doc = db.collection('categories').doc();
      final categoryFinal = category.copyWith(id: doc.id);
      await doc.set(categoryFinal.toFirestore());
    } catch (e) {
      
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String id) {
    // TODO: implement deleteCategory
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getAllCategories()  async {
      try {
      final docs = db
          .collection('categories')
          .withConverter<Category>(
            fromFirestore: Category.fromFirestore,
            toFirestore: (Category category, _) => category.toFirestore(),
          );

      final categories = await docs.get();

      return categories.docs.map((doc) => doc.data()).toList();
    } catch (e) {
    
      rethrow;
    }
  }


  @override
  Future<Category?> getCategoryById(String id) async{
    try {
    final query = db
        .collection('categories')
        .where('id', isEqualTo: id)
        .limit(1)
        .withConverter<Category>(
          fromFirestore: Category.fromFirestore,
          toFirestore: (Category category, _) => category.toFirestore(),
        );

    final docs = await query.get();

    if (docs.docs.isNotEmpty) {
      return docs.docs.first.data();
    }
    return null;
  } catch (e) {
    return null;
  }
}
    
  

  @override
  Future<List<Category>> searchCategory(String query) async {final docs = db
        .collection('categories')
        .withConverter<Category>(
          fromFirestore: Category.fromFirestore,
          toFirestore: (Category category,_) => category.toFirestore(),
        );

    final categories = await docs.get();

    final _categories = categories.docs.map((doc) => doc.data()).toList();

    if (query.trim().isEmpty) return _categories;

    List<Category> exactResults = _categories;

    final lowerQuery = query.toLowerCase().split(" ");
    for (var element in lowerQuery) {
      if (element.isNotEmpty && element != " ") {
        exactResults =
            _categories.where((category) => 
              category.descripcion.toLowerCase().contains(element))
            .toList();
      }
    }

    return exactResults;
  }

  @override
  Future<void> updateCategory(Category category) {
    // TODO: implement updateCategory
    throw UnimplementedError();
  }
}
