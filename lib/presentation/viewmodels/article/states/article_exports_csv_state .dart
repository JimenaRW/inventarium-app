import 'package:inventarium/domain/article.dart';

class ArticleExportsCsvState {
  final List<Article> articles;
  final List<Article> filteredArticles;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? lastExportedCsvUrl;
  final int exportedCount;

  const ArticleExportsCsvState({
    this.articles = const [],
    this.filteredArticles = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.lastExportedCsvUrl,
    this.exportedCount = 0,
  });

  ArticleExportsCsvState copyWith({
    List<Article>? articles,
    List<Article>? filteredArticles,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? lastExportedCsvUrl,
    int? exportedCount,
  }) {
    return ArticleExportsCsvState(
      articles: articles ?? this.articles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      lastExportedCsvUrl: lastExportedCsvUrl ?? this.lastExportedCsvUrl,
      exportedCount: exportedCount ?? this.exportedCount,
    );
  }
}
