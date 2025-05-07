import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_notifier.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/category.dart';


final FirebaseFirestore db = FirebaseFirestore.instance;

Provider<CategoryRepository> categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(db),
);


final categoriesNotifierProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
  (ref) => CategoryNotifier(ref.read(categoryRepositoryProvider)),
);