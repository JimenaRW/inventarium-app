import 'package:collection/collection.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/domain/i_category_repository.dart';

class CategoryRepository implements ICategoryRepository{

  final List<Category> _categories = [
    Category(categoryId: 1, description:'Categoria 1'),
    Category(categoryId: 2, description:'Categoria 2'),
    Category(categoryId: 3, description:'Categoria 3'),
    Category(categoryId: 4, description:'Categoria 4'),
    Category(categoryId: 5, description:'Categoria 5'),
    Category(categoryId: 6, description:'Categoria 6'),
  ];


  @override
  Future<void> addCategory(Category category) =>
    Future.delayed(const Duration(seconds: 2), (){
      _categories.add(category);
      });

  @override
  Future<void> deleteCategory(int id) {
    // TODO: implement deleteCategory
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getAllCategories() =>
   Future.delayed(const Duration(seconds: 2), () => _categories);

  @override
  Future<Category?> getCategoryById(int id) =>
  Future.delayed(const Duration(seconds: 2), ()=>
  _categories.firstWhereOrNull((category)=> category.categoryId == id),);

  @override
  Future<List<Category?>> searchCategory(String query)=>
    Future.delayed(const Duration (seconds: 2),(){
      if(query.trim().isEmpty) return _categories;

      List<Category> exactResults = _categories;

      final lowerQquery = query.toLowerCase().split(" ");
      for (var element in lowerQquery){
        if(element.isNotEmpty && element != " "){
          exactResults = _categories.where((category){
            return category.description.toLowerCase().contains(element);}).toList();
        }
    }
    return exactResults;
    });

  @override
  Future<void> updateCategory(Category category) {
    // TODO: implement updateCategory
    throw UnimplementedError();
  }}