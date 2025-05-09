import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';

class ArticleSearchNotifier extends StateNotifier<ArticleSearchState> {
final ArticleNotifier _articleNotifier;
  final int _currentPage = 1;
  final int _itemsPerPage = 20;

  ArticleSearchNotifier(this._articleNotifier)
    : super(ArticleSearchState.initial());

  Future<void> loadArticles() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _articleNotifier.loadArticles();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar artículos: ${e.toString()}',
      );
    }
  }

  List<Article> get filteredArticles {
    if (state.searchQuery.isEmpty) return state.articles;

    final query = state.searchQuery.toLowerCase();
    final terms = query.split(' ').where((t) => t.isNotEmpty).toList();

    if (terms.isEmpty) return state.articles;

    List<Article> filtro =
        state.articles.where((article) {
          final searchableContent = [
            article.descripcion.toLowerCase(),
            article.sku.toLowerCase(),
            article.codigoBarras?.toLowerCase() ?? '',
          ].join(' ');

          return terms.every((term) => searchableContent.contains(term));
        }).toList();
    return filtro;
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await _articleNotifier.getArticles(page: _currentPage, limit: _itemsPerPage);
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        hasMore: articles.length == _itemsPerPage,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

   Future<void> loadMoreArticles() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final newArticles = await _articleNotifier.getArticles(
        page: state.currentPage + 1,
        limit: _itemsPerPage,
      );
      
      state = state.copyWith(
        articles: [...state.articles, ...newArticles],
        filteredArticles: [...state.filteredArticles, ...newArticles],
        isLoadingMore: false,
        hasMore: newArticles.length == _itemsPerPage,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(filteredArticles: state.articles);
      return;
    }

    state = state.copyWith(isSearching: true);
    try {
      final results = await _articleNotifier.searchArticles(query);
      state = state.copyWith(
        filteredArticles: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }
}
