import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
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
      state = state.copyWith(
        articles: articles,
        filteredArticles: articles,
        isLoading: false,
        hasMore: articles.length == _itemsPerPage,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isDeleted: false,
        articlesDeleted: [],
        errorDeleted: null,
      );
    }
  }

  void clearErrorDeleted() => state = state.copyWith(errorDeleted: null);
  void clearSuccessMessage() => state = state.copyWith(successMessage: null);

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

  void updateStock(String id, int newStock) async {
    try {
      await _articleNotifier.updateStock(id, newStock);
      final updatedArticles =
          state.articles.map((article) {
            if (article.id == id) {
              return article.copyWith(stock: newStock);
            }
            return article;
          }).toList();

      state = state.copyWith(
        articles: updatedArticles,
        filteredArticles: getFilteredArticles(updatedArticles),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar el stock: ${e.toString()}',
      );
    }
  }

  void toggleDeleteMode(bool enabled) {
    state = state.copyWith(isDeleted: enabled, articlesDeleted: []);
  }

  void toggleDeleteList(bool bool, String idArticle) {
    if (bool) {
      state = state.copyWith(
        articlesDeleted: [...state.articlesDeleted, idArticle],
      );
    } else {
      state = state.copyWith(
        articlesDeleted: [
          ...state.articlesDeleted.where((art) => art != idArticle),
        ],
      );
    }
  }

  Future<void> searchArticlesByNoStock() async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await _articleNotifier.getArticlesWithNoStock();
      state = state.copyWith(filteredArticles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchArticlesByLowStock(int threshold) async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await _articleNotifier.getArticlesWithLowStock(
        threshold,
      );
      state = state.copyWith(filteredArticles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeAllArticles() async {
    state = state.copyWith(isLoading: true);

    try {
      final firestore = FirebaseFirestore.instance;
      final articlesRef = firestore.collection('articles');

      final estadosPermitidos = [
        ArticleStatus.active.toString(),
        ArticleStatus.suspended.toString(),
      ];

      final querySnapshot =
          await articlesRef
              .where(FieldPath.documentId, whereIn: state.articlesDeleted)
              .where('status', whereIn: estadosPermitidos)
              .get();

      if (querySnapshot.docs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorDeleted:
              "No existen artículos en estado activo o suspendido que eliminar.",
        );

        return;
      }

      const maxBatchSize = 500;
      final totalBatches = (querySnapshot.docs.length / maxBatchSize).ceil();

      for (int i = 0; i < totalBatches; i++) {
        final batch = firestore.batch();
        final batchDocs = querySnapshot.docs
            .skip(i * maxBatchSize)
            .take(maxBatchSize);

        for (final doc in batchDocs) {
          batch.update(doc.reference, {'status': ArticleStatus.inactive.name});
        }

        await batch.commit();

        if (i < totalBatches - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      state = state.copyWith(
        articlesDeleted: [],
        isDeleted: false,
        isLoading: false,
        errorDeleted: null,
        successMessage: "Borrado masivo exitoso!",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDeleted:
            "No logro eliminar la lista de artículos: ${e.toString()}",
      );
    }
  }
}
