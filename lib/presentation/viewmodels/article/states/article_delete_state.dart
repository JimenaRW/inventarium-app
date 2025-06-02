class ArticleDeleteState {
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  ArticleDeleteState({
    required this.isLoading,
    this.errorMessage,
    required this.success,
  });

  ArticleDeleteState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return ArticleDeleteState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      success: success ?? this.success,
    );
  }
}
