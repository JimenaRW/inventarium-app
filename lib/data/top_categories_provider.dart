import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/domain/category.dart';
import 'package:inventarium/domain/article.dart';

final allArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final articlesRepository = ref.read(articleRepositoryProvider);
  try {
    final articles = await articlesRepository.getAllArticles();
    return articles;
  } catch (error) {
    rethrow;
  }
});

final topCategoriesProvider =
    StateNotifierProvider<TopCategoriesNotifier, AsyncValue<Map<String, int>>>((
      ref,
    ) {
      return TopCategoriesNotifier(ref);
    });

class TopCategoriesNotifier
    extends StateNotifier<AsyncValue<Map<String, int>>> {
  final Ref _ref;

  TopCategoriesNotifier(this._ref) : super(const AsyncValue.loading()) {
    build(); // lo llamás al iniciar
  }

  Future<void> build() async {
    try {
      state = const AsyncValue.loading();

      final articles =
          await _ref.read(articleRepositoryProvider).getAllArticles();
      final categories =
          await _ref.read(categoryRepositoryProvider).getAllCategories();

      final categoryIdCounts = <String, int>{};
      for (final article in articles) {
        if (article.category.isNotEmpty) {
          categoryIdCounts.update(
            article.category,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      final categoryDescriptionCounts = <String, int>{};
      for (final category in categories) {
        final count = categoryIdCounts[category.id] ?? 0;
        categoryDescriptionCounts[category.description] = count;
      }

      final sortedCategoryCounts =
          categoryDescriptionCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      final topCategoriesData = Map.fromEntries(
        sortedCategoryCounts.where((entry) => entry.value > 0).take(5),
      );

      state = AsyncValue.data(topCategoriesData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
