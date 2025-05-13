class ArticleUpdateState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  ArticleUpdateState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  ArticleUpdateState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return ArticleUpdateState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }

  factory ArticleUpdateState.initial() {
    return ArticleUpdateState();
  }
}
