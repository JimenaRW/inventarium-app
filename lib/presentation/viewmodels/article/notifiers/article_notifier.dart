import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_state.dart';

class ArticleNotifier extends StateNotifier<ArticleState> {
  final ArticleRepository _repository;

  ArticleNotifier(this._repository) : super(const ArticleState());

  Future<void> loadArticles() async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await _repository.getArticles();
      state = state.copyWith(
        articles: articles,
        filteredArticles: articles,
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
    final lowerQuery = query.toLowerCase();
    final filtered =
        state.articles.where((article) {
          return article.sku.toLowerCase().contains(lowerQuery) ||
              article.descripcion.toLowerCase().contains(lowerQuery) ||
              (article.codigoBarras != null &&
                  article.codigoBarras!.toLowerCase().contains(lowerQuery));
        }).toList();

    state = state.copyWith(searchQuery: query, filteredArticles: filtered);
  }

  Future<void> addArticle(Article article) async {
    state = state.copyWith(isLoading: true);
    try {
      final createdArticle = await _repository.addArticle(article);
      
      final updatedArticles = [...state.articles, createdArticle];
      
      state = state.copyWith(
        articles: updatedArticles,
        filteredArticles: updatedArticles,
        isLoading: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al agregar artículo: ${e.toString()}',
      );
      rethrow;
    }
  }
}
