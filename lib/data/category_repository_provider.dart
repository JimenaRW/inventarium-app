import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/category_repository.dart';

Provider<CategoryRepository> categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(),
);