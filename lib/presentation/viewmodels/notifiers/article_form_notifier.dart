import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/states/article_form_state.dart';

class ArticleFormNotifier extends StateNotifier<ArticleFormState> {
  final ArticleRepository _articleRepository;

  ArticleFormNotifier(this._articleRepository) : super(ArticleFormState());

  Future<void> submitForm(Article article) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _articleRepository.addArticle(article);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al crear el artículo: ${e.toString()}',
      );
    }
  }

  void resetState() {
    state = ArticleFormState();
  }
}