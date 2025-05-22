import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_delete_notifier.dart';
import 'package:inventarium/data/category_notifier.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/presentation/viewmodels/article/states/category_delete_state.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepository(db));

final categoriesNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
      (ref) => CategoryNotifier(ref.read(categoryRepositoryProvider)),
    );

final categoryDeleteNotifierProvider = StateNotifierProvider.autoDispose<
  CategoryDeleteNotifier,
  CategoryDeleteState
>((ref) {
  final repository = ref.read(
    categoriesNotifierProvider.notifier,
  ); // Esto lo obtienes de tu provider
  return CategoryDeleteNotifier(repository);
});
