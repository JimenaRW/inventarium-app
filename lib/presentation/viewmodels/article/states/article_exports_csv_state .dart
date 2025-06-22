// ignore_for_file: file_names

import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';

class ArticleExportsCsvState {
  final List<Article> articles;
  final List<Article> filteredArticles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSearching;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String searchQuery;
  final ArticleStatus? status;
  final String? lastExportedCsvUrl;
  final int exportedCount;

  const ArticleExportsCsvState({
     this.articles = const [],
    this.filteredArticles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.error,
    this.searchQuery = '',
    this.status,
    this.lastExportedCsvUrl,
    this.exportedCount = 0,
  });

  ArticleExportsCsvState copyWith({
    List<Article>? articles,
    List<Article>? filteredArticles,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSearching,
    bool? hasMore,
    int? currentPage,
    String? error,
    ArticleStatus? status,
    String? lastExportedCsvUrl,
    int? exportedCount,
  }) {
    return ArticleExportsCsvState(
      articles: articles ?? this.articles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
      status: status ?? this.status,
      lastExportedCsvUrl: lastExportedCsvUrl ?? this.lastExportedCsvUrl,
      exportedCount: exportedCount ?? this.exportedCount,
    );
  }

  factory ArticleExportsCsvState.initial() => ArticleExportsCsvState(
    articles: [],
    filteredArticles: [],
    isLoading: false,
    isLoadingMore: false,
    isSearching: false,
    hasMore: true,
    currentPage: 0,
    status: ArticleStatus.active,
  );

}
