import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';

class ArticleSearchNotifier extends StateNotifier<ArticleSearchState> {
  final ArticleNotifier _articleNotifier;
  final int _currentPage = 1;
  final int _itemsPerPage = 10;

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
      final articles = await _articleNotifier.getArticles(
        page: _currentPage,
        limit: _itemsPerPage,
      );
      print('Artículos cargados: ${articles.length}');
      state = state.copyWith(
        articles: articles,
        filteredArticles: articles, // Agrega esto
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

      final filteredNewArticles = getFilteredArticles(newArticles);

      state = state.copyWith(
        articles: [...state.articles, ...newArticles],
        filteredArticles: [...state.filteredArticles, ...filteredNewArticles],
        isLoadingMore: false,
        hasMore: newArticles.length == _itemsPerPage,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  List<Article> getFilteredArticles(List<Article> articles) {
    if (state.searchQuery.isEmpty) return articles;

    final query = state.searchQuery.toLowerCase();
    final terms = query.split(' ').where((t) => t.isNotEmpty).toList();

    if (terms.isEmpty) return articles;

    return articles.where((article) {
      final searchableContent = [
        article.descripcion.toLowerCase(),
        article.sku.toLowerCase(),
        article.codigoBarras?.toLowerCase() ?? '',
      ].join(' ');

      return terms.every((term) => searchableContent.contains(term));
    }).toList();
  }

  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(filteredArticles: state.articles);
      return;
    }

    state = state.copyWith(isSearching: true);
    try {
      final results = await _articleNotifier.searchArticles(query);
      state = state.copyWith(filteredArticles: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  Future<void> updateStock(String id, int newStock) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _articleNotifier.updateStock(id, newStock);

      final updatedAll =
          state.articles.map((art) {
            return art.id == id ? art.copyWith(stock: newStock) : art;
          }).toList();

      final updatedFiltered =
          state.searchQuery.isEmpty
              ? updatedAll
              : updatedAll.where((art) {
                final q = state.searchQuery.toLowerCase();
                return art.descripcion.toLowerCase().contains(q) ||
                    art.sku.toLowerCase().contains(q) ||
                    (art.codigoBarras ?? '').toLowerCase().contains(q);
              }).toList();

      state = state.copyWith(
        articles: updatedAll,
        filteredArticles: updatedFiltered,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudo actualizar el stock: ${e.toString()}',
      );
    }
  }
}
