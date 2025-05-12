import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_state.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_update_state.dart';

class ArticleUpdateNotifier extends StateNotifier<ArticleUpdateState> {
  final ArticleRepository _articleRepository;

  ArticleUpdateNotifier(this._articleRepository)
    : super(ArticleUpdateState.initial());

  Future<void> updateArticle(Article article) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _articleRepository.updateArticle(article);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar: ${e.toString()}',
      );
    }
  }
}
