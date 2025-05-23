import 'package:inventarium/domain/article.dart';

class ArticleSearchState {
  final List<Article> articles;
  final List<Article> filteredArticles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSearching;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String searchQuery;
  final bool isDeleted;
  final List<String> articlesDeleted;

  const ArticleSearchState({
    this.articles = const [],
    this.filteredArticles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.error,
    this.searchQuery = '',
    this.isDeleted = false,
    this.articlesDeleted = const [],
  });

  factory ArticleSearchState.initial() => ArticleSearchState(
    articles: [],
    filteredArticles: [],
    isLoading: false,
    isLoadingMore: false,
    isSearching: false,
    hasMore: true,
    currentPage: 0,
    isDeleted: false,
    articlesDeleted: [],
  );

  ArticleSearchState copyWith({
    List<Article>? articles,
    List<Article>? filteredArticles,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSearching,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? isDeleted,
    List<String>? articlesDeleted,
  }) {
    return ArticleSearchState(
      articles: articles ?? this.articles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
      isDeleted: isDeleted ?? this.isDeleted,
      articlesDeleted: articlesDeleted ?? this.articlesDeleted,
    );
  }
}