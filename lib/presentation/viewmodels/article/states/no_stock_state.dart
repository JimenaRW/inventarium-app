import 'package:inventarium/domain/article.dart';

class NoStockArticlesState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;

  NoStockArticlesState({
    this.articles = const [],
    this.isLoading = false,
    this.error,
  });

  // Opcional:
  NoStockArticlesState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? error,
  }) {
    return NoStockArticlesState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
