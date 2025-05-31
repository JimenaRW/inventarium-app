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
    _init();
  }

  Future<void> _init() async {
    try {
      final articlesState = _ref.watch(allArticlesProvider);
      final categoriesState = _ref.watch(categoriesNotifierProvider);

      if (articlesState is AsyncLoading || categoriesState is AsyncLoading) {
        state = const AsyncValue.loading();
        return;
      }

      if (articlesState is AsyncError) {
        state = AsyncValue.error(
          articlesState.error!,
          articlesState.stackTrace!,
        );
        return;
      }
      if (categoriesState is AsyncError) {
        state = AsyncValue.error(
          categoriesState.error!,
          categoriesState.stackTrace!,
        );
        return;
      }

      final List<Article> articles = articlesState.value ?? [];
      final List<Category> categories = categoriesState.value ?? [];

      final categoryIdCounts = <String, int>{};
      for (final article in articles) {
        if (article.categoria.isNotEmpty) {
          categoryIdCounts.update(
            article.categoria,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      final categoryDescriptionCounts = <String, int>{};
      for (final category in categories) {
        final count = categoryIdCounts[category.id] ?? 0;
        categoryDescriptionCounts[category.descripcion] = count;
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
