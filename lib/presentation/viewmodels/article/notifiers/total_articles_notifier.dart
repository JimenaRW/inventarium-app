import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';

class TotalArticlesNotifier extends AutoDisposeAsyncNotifier<int> {
  Future<ArticleRepository> get _articleRepository async =>
      ref.read(articleRepositoryProvider);

  @override
  Future<int> build() async {
    return await _fetchTotalArticles();
  }

  Future<int> _fetchTotalArticles() async {
    try {
      final repository = await _articleRepository;
      final articles = await repository.getAllArticles();
      return articles.length;
    } catch (e, stackTrace) {
      print('Error getting total articles: $e\n$stackTrace');
      return 0; // O manejar el error de otra forma
    }
  }
}
