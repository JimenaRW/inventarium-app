import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/states/article_search_state.dart';

class ArticleSearchNotifier extends StateNotifier<ArticleSearchState> {
  final ArticleRepository _repository;

  ArticleSearchNotifier(this._repository) : super(const ArticleSearchState());

  Future<void> loadArticles() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final articles = await _repository.getAllArticles();
      state = state.copyWith(
        articles: articles,
        isLoading: false,
      );
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
    
    return state.articles.where((article) {
      return article.sku.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
             article.descripcion.toLowerCase().contains(state.searchQuery.toLowerCase());
    }).toList();
  }
}