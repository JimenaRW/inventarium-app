import 'package:inventarium/domain/article.dart';

class ArticleState {
  final List<Article> articles;
  final List<Article> filteredArticles;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? lastExportedCsvUrl;

  const ArticleState({
    this.articles = const [],
    this.filteredArticles = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.lastExportedCsvUrl,
  });

  ArticleState copyWith({
    List<Article>? articles,
    List<Article>? filteredArticles,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? lastExportedCsvUrl,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      lastExportedCsvUrl: lastExportedCsvUrl ?? this.lastExportedCsvUrl,
    );
  }
}