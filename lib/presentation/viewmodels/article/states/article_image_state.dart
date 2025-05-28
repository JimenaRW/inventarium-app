class ArticleImageState {
  final bool isLoading;
  final String? imageUrl;
  final String? error;
  final bool success;

  const ArticleImageState({
    this.isLoading = false,
    this.imageUrl,
    this.error,
    this.success = false,
  });

  ArticleImageState copyWith({
    bool? isLoading,
    String? imageUrl,
    String? error,
    bool? success,
  }) {
    return ArticleImageState(
      isLoading: isLoading ?? this.isLoading,
      imageUrl: imageUrl ?? this.imageUrl,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}
