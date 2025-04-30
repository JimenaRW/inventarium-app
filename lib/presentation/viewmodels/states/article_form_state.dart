class ArticleFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ArticleFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ArticleFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ArticleFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}