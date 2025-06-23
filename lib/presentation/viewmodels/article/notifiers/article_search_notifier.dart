import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';

class ArticleSearchNotifier extends StateNotifier<ArticleSearchState> {
  final ArticleNotifier _articleNotifier;
  final int _itemsPerPage = 10;
  List<Article> _all = [];
  List<Article> _active = [];
  List<Article> _inactive = [];

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

  Future<String?> loadImageWithTokenRetry(Article article) async {
    try {
      return await _articleNotifier.regenerateImageUrl(article);
    } catch (e) {
      return null;
    }
  }

  void loadArticlesByStatus(ArticleStatus? status) async {
    state = state.copyWith(isLoading: true);
    try {
      await _articleNotifier
          .getArticles(page: 1, limit: _itemsPerPage, status: status)
          .then(
            (value) => {
              state = state.copyWith(
                articles: value,
                isLoading: false,
                hasMore: value.length == _itemsPerPage,
                status: status,
                currentPage: 1,
              ),
              state = state.copyWith(filteredArticles: filteredArticles),
            },
          );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  List<Article> get filteredArticles {
    if (state.searchQuery.isEmpty) return state.articles;

    final query = state.searchQuery.toLowerCase();
    final terms = query.split(' ').where((t) => t.isNotEmpty).toList();

    if (terms.isEmpty) return state.articles;

    List<Article> mappedArticles =
        state.articles.where((article) {
          final searchableContent = [
            article.description.toLowerCase(),
            article.sku.toLowerCase(),
            article.barcode?.toLowerCase() ?? '',
          ].join(' ');

          return terms.every((term) => searchableContent.contains(term));
        }).toList();
    return mappedArticles;
  }

  void filterArticlesByStatus(ArticleStatus? status) {
    print("filterArticlesByStatus llamado con status: $status");
    if (status == null) {
      state = state.copyWith(filteredArticles: state.articles, status: status);
    } else {
      state = state.copyWith(status: status);
      _applyFilters();
    }
  }

  Future<void> searchArticles(String query) async {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    List<Article> filteredArticles = state.articles;

    if (state.searchQuery.isNotEmpty) {
      filteredArticles =
          filteredArticles.where((article) {
            final searchableContent = [
              article.description.toLowerCase(),
              article.sku.toLowerCase(),
              article.barcode?.toLowerCase() ?? '',
            ].join(' ');

            return searchableContent.contains(state.searchQuery.toLowerCase());
          }).toList();
    }

    state = state.copyWith(filteredArticles: filteredArticles);
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, isSpecialFilter: false);
    try {
      final articles = await _articleNotifier.getAllArticlesWithoutPagination();

      _all = articles;
      _active =
          articles.where((a) => a.status == ArticleStatus.active.name).toList();
      _inactive =
          articles
              .where((a) => a.status == ArticleStatus.inactive.name)
              .toList();

      selectFilterStatus(null); // fuerza filtro a "Todos"
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectFilterStatus(ArticleStatus? status) {
    List<Article> baseList;

    if (status == null) {
      baseList = _all;
    } else if (status == ArticleStatus.active) {
      baseList = _active;
    } else {
      baseList = _inactive;
    }

    final filtered = getFilteredArticles(baseList);

    state = state.copyWith(
      status: status,
      articles: baseList, // ← 🔥 Esto es clave
      filteredArticles: filtered, // ← y esto
      searchQuery: '',
    );
  }

  void clearErrorDeleted() => state = state.copyWith(errorDeleted: null);
  void clearSuccessMessage() => state = state.copyWith(successMessage: null);

  Future<void> loadMoreArticles() async {
    if (state.isLoadingMore || !state.hasMore || state.isSpecialFilter) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final newArticles = await _articleNotifier.getArticles(
        page: state.currentPage + 1,
        limit: _itemsPerPage,
        status: state.status,
      );

      state = state.copyWith(
        articles: [...state.articles, ...newArticles],
        filteredArticles: [...state.filteredArticles, ...newArticles],
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
        article.description.toLowerCase(),
        article.sku.toLowerCase(),
        article.barcode?.toLowerCase() ?? '',
      ].join(' ');

      return terms.every((term) => searchableContent.contains(term));
    }).toList();
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
    state = state.copyWith(isLoading: true, isSpecialFilter: true);
    try {
      final articles = await _articleNotifier.getArticlesWithNoStock();
      state = state.copyWith(filteredArticles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchArticlesByLowStock(int threshold) async {
    state = state.copyWith(isLoading: true, isSpecialFilter: true);
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

      final allowedStates = [
        ArticleStatus.active.name,
        ArticleStatus.suspended.name,
      ];

      final ids = state.articlesDeleted;
      if (ids.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorDeleted: "No hay artículos seleccionados para eliminar.",
        );
        return;
      }

      // Dividir en chunks de 10 por limitación de Firestore
      const chunkSize = 10;
      final chunks = List.generate(
        (ids.length / chunkSize).ceil(),
        (i) => ids.skip(i * chunkSize).take(chunkSize).toList(),
      );

      List<DocumentSnapshot> allDocs = [];

      for (final chunk in chunks) {
        final snapshot =
            await articlesRef
                .where(FieldPath.documentId, whereIn: chunk)
                .where('status', whereIn: allowedStates)
                .get();
        allDocs.addAll(snapshot.docs);
      }

      if (allDocs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorDeleted:
              "No existen artículos en estado activo o suspendido que eliminar.",
        );
        return;
      }

      const maxBatchSize = 500;
      final totalBatches = (allDocs.length / maxBatchSize).ceil();

      for (int i = 0; i < totalBatches; i++) {
        final batch = firestore.batch();
        final batchDocs = allDocs.skip(i * maxBatchSize).take(maxBatchSize);

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
