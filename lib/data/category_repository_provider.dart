import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_notifier.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/category.dart';

Provider<CategoryRepository> categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(),
);


final categoriesNotifierProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
  (ref) => CategoryNotifier(ref.read(categoryRepositoryProvider)),
);