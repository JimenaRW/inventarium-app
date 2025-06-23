import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_exports_csv_state%20.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ArticleExportsCsvNotifier extends StateNotifier<ArticleExportsCsvState> {
  final ArticleNotifier _articleNotifier;
  final int _itemsPerPage = 10;

  ArticleExportsCsvNotifier(this._articleNotifier)
    : super(ArticleExportsCsvState.initial());

  Future<void> loadInitialData() async {
    loadArticlesByStatus(null);
  }

  void loadArticlesByStatus(ArticleStatus? status) async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await _articleNotifier.getArticles(
        page: 1,
        limit: _itemsPerPage,
        status: status,
      );
      final articleCount = await _articleNotifier.getArticleCount();
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        hasMore: articles.length == _itemsPerPage,
        exportedCount: articleCount,
        status: status,
        currentPage: 1,
      );
      state = state.copyWith(filteredArticles: filteredArticles);
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

  Future<void> loadMoreArticles() async {
    if (state.isLoadingMore || !state.hasMore) return;

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

  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(filteredArticles: state.articles);
      return;
    }

    state = state.copyWith(isSearching: true);
    try {
      final filteredArticles =
          state.articles.where((article) {
            final searchableContent = [
              article.description.toLowerCase(),
              article.sku.toLowerCase(),
              article.barcode?.toLowerCase() ?? '',
            ].join(' ');

            return searchableContent.contains(query.toLowerCase());
          }).toList();

      state = state.copyWith(
        filteredArticles: filteredArticles,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  Future<void> exportArticles() async {
    try {
      state = state.copyWith(isLoading: true);

      String url = await _articleNotifier.exportArticles();

      state = state.copyWith(isLoading: false, lastExportedCsvUrl: url);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> shareFileWithDownload(String storagePath) async {
    try {
      final response = await http.get(Uri.parse(storagePath));

      final responseBytes = response.bodyBytes;
      bool hasBom =
          responseBytes.length >= 3 &&
          responseBytes[0] == 0xEF &&
          responseBytes[1] == 0xBB &&
          responseBytes[2] == 0xBF;

      final fileBytes =
          hasBom ? responseBytes : <int>[0xEF, 0xBB, 0xBF, ...responseBytes];

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final formatted = formatDate(
        now,
      ); 
      final tempFile = File('${tempDir.path}/artículos-$formatted.csv');

      await tempFile.writeAsBytes(fileBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(
          tempFile.path,
          mimeType: 'text/csv',
          name: 'articulos-$formatted.csv',
        ),
      ], text: 'Compartir archivo');
    } catch (e) {
      state = state.copyWith(
        error: 'Error al compartir archivo: ${e.toString()}',
      );
    }
  }

  String formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final day = twoDigits(date.day);
    final month = twoDigits(date.month);
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  String convertPublicUrlToGsUrl(String publicUrl) {
    final uri = Uri.parse(publicUrl);
    final bucket = 'inventarium-th3-2025.appspot.com';
    final objectPath = Uri.decodeFull(uri.pathSegments[4]);
    return 'gs://$bucket/$objectPath';
  }
}
