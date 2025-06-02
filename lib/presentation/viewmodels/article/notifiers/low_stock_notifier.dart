import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/low_stock_state.dart';

const int _lowStockThreshold = 10;

class LowStockArticlesNotifier
    extends AutoDisposeAsyncNotifier<LowStockArticlesState> {
  Future<ArticleRepository> get _articleRepository async =>
      ref.read(articleRepositoryProvider);

  @override
  Future<LowStockArticlesState> build() async {
    final result = await _fetchLowStockArticles();

    return result;
  }

  Future<LowStockArticlesState> _fetchLowStockArticles() async {
    try {
      final repository = await _articleRepository;
      final articles = await repository.getArticlesWithLowStock(
        _lowStockThreshold,
      );

      return LowStockArticlesState(articles: articles);
    } catch (e) {
      return LowStockArticlesState(error: e.toString());
    }
  }
}
