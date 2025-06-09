import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/no_stock_state.dart';

class NoStockArticlesNotifier
    extends AutoDisposeAsyncNotifier<NoStockArticlesState> {
  Future<ArticleRepository> get _articleRepository async =>
      ref.read(articleRepositoryProvider);

  @override
  Future<NoStockArticlesState> build() async {
    try {
      final result = await _fetchNoStockArticles();
      return result;
    } catch (e) {
      return NoStockArticlesState(error: e.toString());
    }
  }

  Future<NoStockArticlesState> _fetchNoStockArticles() async {
    try {
      final repository = await _articleRepository;
      final articles = await repository.getArticlesWithNoStock();

      return NoStockArticlesState(articles: articles);
    } catch (e) {
      return NoStockArticlesState(error: e.toString());
    }
  }

  Future<void> loadArticlesWithNoStock() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchNoStockArticles);
  }
}
