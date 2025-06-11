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
  final String? errorDeleted;
  final String? successMessage;

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
    this.errorDeleted,
    this.successMessage,
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
    errorDeleted: null,
    successMessage: null,
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
    String? errorDeleted,
    String? successMessage,
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
      errorDeleted: errorDeleted ?? this.errorDeleted,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}