import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
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
            final categoryDescription =
                categories
                    .firstWhereOrNull((x) => x.id.contains(article.category))
                    ?.description;

            return article.copyWith(categoryDescription: categoryDescription);
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
    final mappedArticles =
        state.articles.where((article) {
          return article.sku.toLowerCase().contains(lowerQuery) ||
              article.description.toLowerCase().contains(lowerQuery) ||
              (article.barcode != null &&
                  article.barcode!.toLowerCase().contains(lowerQuery));
        }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredArticles: mappedArticles,
    );
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
      final categories = await _repositoryCategories.getAllCategories();
      final updatedArticles =
          articles.map((article) {
            final categoriaDescripcion =
                categories
                    .firstWhereOrNull((x) => x.id.contains(article.category))
                    ?.description;

            return article.copyWith(categoryDescription: categoriaDescripcion);
          }).toList();

      return updatedArticles;
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

  Future<void> loadArticleById(String id) async {
    try {
      final article = await _repository.getArticleById(id);
      final categories = await _repositoryCategories.getAllCategories();
      final categoryDescription =
          categories
              .firstWhereOrNull((x) => x.id.contains(article?.category ?? ''))
              ?.description;

      if (article != null) {
        final updatedArticle = article.copyWith(
          categoryDescription: categoryDescription,
        );
        state = state.copyWith(articles: [...state.articles, updatedArticle]);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al cargar artículo: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> softDeleteById(String id) async {
    try {
      final article = await _repository.getArticleById(id);

      if (article == null) {
        throw ("El artículo no se encuentra disponible en la base de datos.",);
      }

      if (article.status == ArticleStatus.inactive.name) {
        throw ("El artículo ya se encuentra inactivo.");
      }

      final softDeleteArticle = article.copyWith(
        status: ArticleStatus.inactive.name,
      );

      await _repository.deleteArticle(softDeleteArticle);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStock(String id, int newStock) {
    return _repository.updateStock(id, newStock);
  }

  Future<List<Article>> getArticlesWithNoStock() async {
    var articles = await _repository.getArticlesWithNoStock();

    final categories = await _repositoryCategories.getAllCategories();

    final updatedArticles =
        articles.map((article) {
          final categoryDescription =
              categories
                  .firstWhereOrNull((x) => x.id.contains(article.category))
                  ?.description;

          return article.copyWith(categoryDescription: categoryDescription);
        }).toList();

    return updatedArticles;
  }

  Future<List<Article>> getArticlesWithLowStock(int threshold) async {
    var articles = await _repository.getArticlesWithLowStock(threshold);

    final categories = await _repositoryCategories.getAllCategories();

    final updatedArticles =
        articles.map((article) {
          final categoryDescription =
              categories
                  .firstWhereOrNull((x) => x.id.contains(article.category))
                  ?.description;

          return article.copyWith(categoryDescription: categoryDescription);
        }).toList();

    return updatedArticles;
  }
}
