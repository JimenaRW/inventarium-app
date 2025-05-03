import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';

class ArticleSearchNotifier extends StateNotifier<ArticleSearchState> {
final ArticleNotifier _articleNotifier;

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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
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
}
