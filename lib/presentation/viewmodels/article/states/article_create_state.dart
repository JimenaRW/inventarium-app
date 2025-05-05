import 'package:inventarium/domain/article.dart';

class ArticleCreateState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final Article? draft;

  ArticleCreateState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.draft,
  });

  ArticleCreateState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    Article? draft,
  }) {
    return ArticleCreateState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      draft: draft ?? this.draft,
    );
  }

   factory ArticleCreateState.initial() {
    return ArticleCreateState();
  }
}