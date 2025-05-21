import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_delete_state.dart';

class ArticleDeleteNotifier extends StateNotifier<ArticleDeleteState>  {
  final ArticleNotifier repository;

  ArticleDeleteNotifier(this.repository) : super(ArticleDeleteState(isLoading: false, success: false, errorMessage: null));


  Future<void> deleteArticle(String articleId) async {
    state = state.copyWith(isLoading: true, errorMessage: null); 

    try {
      await repository.softDeleteById(articleId); 
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Error: ${e.toString()}');
    }
  }

   void resetState() {
    state = ArticleDeleteState(isLoading: false, success: false, errorMessage: null);
  }
}
