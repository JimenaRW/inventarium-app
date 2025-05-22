import 'package:inventarium/domain/article.dart';

class ArticleState {
  final List<Article> articles;
  final List<Article> filteredArticles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSearching;
  final String? error;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;

  const ArticleState({
    this.articles = const [],
    this.filteredArticles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.error,
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasMore = true,
  });

  ArticleState copyWith({
    List<Article>? articles,
    List<Article>? filteredArticles,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSearching,
    String? error,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
