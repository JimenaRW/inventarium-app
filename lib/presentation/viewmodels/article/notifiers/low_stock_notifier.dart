import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/low_stock_state.dart';

const int _lowStockThreshold = 10; // Valor configurable para stock bajo

class LowStockArticlesNotifier
    extends AutoDisposeAsyncNotifier<LowStockArticlesState> {
  Future<ArticleRepository> get _articleRepository async =>
      ref.read(articleRepositoryProvider);

  @override
  Future<LowStockArticlesState> build() async {
    return await _fetchLowStockArticles();
  }

  Future<LowStockArticlesState> _fetchLowStockArticles() async {
    try {
      final repository = await _articleRepository;
      final articles = await repository.getArticlesWithLowStock(
        _lowStockThreshold,
      );
      return LowStockArticlesState(articles: articles);
    } catch (e, stackTrace) {
      print('Error loading articles with low stock: $e\n$stackTrace');
      return LowStockArticlesState(error: e.toString());
    }
  }
}
