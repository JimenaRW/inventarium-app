import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_create_state.dart';

class ArticleCreateNotifier extends StateNotifier<ArticleCreateState> {
  final ArticleNotifier _articleNotifier;

  ArticleCreateNotifier(this._articleNotifier)
    : super(ArticleCreateState.initial());

  Future<void> submitForm(Article newArticle) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _articleNotifier.addArticle(newArticle);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al guardar: ${e.toString()}',
      );
    }
  }

  void updateDraft(Article draft) {
    state = state.copyWith(draft: draft);
  }

  void resetState() {
    state = ArticleCreateState();
  }
}
