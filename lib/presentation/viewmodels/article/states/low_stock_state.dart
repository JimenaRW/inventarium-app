import 'package:inventarium/domain/article.dart';

class LowStockArticlesState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;

  LowStockArticlesState({
    this.articles = const [],
    this.isLoading = false,
    this.error,
  });
}
