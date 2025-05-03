import 'package:inventarium/domain/article.dart';

class ArticleSearchState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const ArticleSearchState({
    this.articles = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ArticleSearchState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ArticleSearchState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  factory ArticleSearchState.initial() {
    return ArticleSearchState();
  }
}



