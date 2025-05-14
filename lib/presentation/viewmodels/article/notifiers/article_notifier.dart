import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_state.dart';

class ArticleNotifier extends StateNotifier<ArticleState> {
  final ArticleRepository _repository;
  final CategoryRepository _repositoryCategories;

  ArticleNotifier(this._repository, this._repositoryCategories)
    : super(const ArticleState());

  Future<void> loadArticles() async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await _repository.getArticles();
      final categories = await _repositoryCategories.getAllCategories();

      final updatedArticles =
          articles.map((article) {
            final categoriaDescripcion =
                categories
                    .firstWhereOrNull((x) => x.id.contains(article.categoria))
                    ?.descripcion;

            return article.copyWith(categoriaDescripcion: categoriaDescripcion);
          }).toList();

      state = state.copyWith(
        articles: updatedArticles,
        filteredArticles: updatedArticles,
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

  Future<List<Article>> getArticles({int page = 1, int limit = 20}) async {
    try {
      final articles = await _repository.getArticlesPaginado(
        page: page,
        limit: limit,
      );
      return articles;
    } catch (e) {
      throw Exception('Error al cargar artículos: ${e.toString()}');
    }
  }

  Future<List<Article>> searchArticles(String query) async {
    try {
      final articles = await _repository.searchArticles(query);
      return articles;
    } catch (e) {
      throw Exception('Error en búsqueda: ${e.toString()}');
    }
  }

  Future<void> exportArticles() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
