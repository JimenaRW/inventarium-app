import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/no_stock_state.dart';

class NoStockArticlesNotifier
    extends AutoDisposeAsyncNotifier<NoStockArticlesState> {
  // Cambiado a AutoDisposeAsyncNotifier
  Future<ArticleRepository> get _articleRepository async =>
      ref.read(articleRepositoryProvider);

  @override
  Future<NoStockArticlesState> build() async {
    print('NoStockNotifier build() llamado - Estado actual: ${state}');
    try {
      final result = await _fetchNoStockArticles();
      print(
        'NoStockNotifier build() - Estado final (AsyncData): AsyncData($result)',
      ); // Imprime como AsyncData
      return result; // Devolver directamente el estado
    } catch (e, st) {
      print(
        'NoStockNotifier build() - Estado final (AsyncError): AsyncError($e)',
      );
      return NoStockArticlesState(error: e.toString());
    }
  }

  Future<NoStockArticlesState> _fetchNoStockArticles() async {
    try {
      final repository = await _articleRepository;
      final articles = await repository.getArticlesWithNoStock();
      print(
        'NoStockNotifier _fetchNoStockArticles() - Datos obtenidos: $articles',
      ); // <---- PASO 2
      return NoStockArticlesState(articles: articles);
    } catch (e, stackTrace) {
      print('Error loading articles with no stock: $e\n$stackTrace');
      return NoStockArticlesState(error: e.toString());
    }
  }

  Future<void> loadArticlesWithNoStock() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchNoStockArticles);
  }
}
