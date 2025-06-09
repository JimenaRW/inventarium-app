import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_update_state.dart';
import 'package:inventarium/data/no_stock_provider.dart'; // Importa noStockProvider

class ArticleUpdateNotifier extends StateNotifier<ArticleUpdateState> {
  final ArticleRepository _articleRepository;
  final Ref _ref;

  ArticleUpdateNotifier(this._articleRepository, this._ref)
    : super(ArticleUpdateState.initial());

  Future<void> updateArticle(Article article) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _articleRepository.updateArticle(article);
      state = state.copyWith(isLoading: false, isSuccess: true);

      if (article.stock == 0) {
        _ref.invalidate(noStockProvider);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar: ${e.toString()}',
        isSuccess: false,
      );
    }
  }
}

final articleUpdateProvider =
    StateNotifierProvider<ArticleUpdateNotifier, ArticleUpdateState>((ref) {
      return ArticleUpdateNotifier(ref.read(articleRepositoryProvider), ref);
    });
