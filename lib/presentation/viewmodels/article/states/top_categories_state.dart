class TopCategoriesState {
  final Map<String, int> topCategories;
  final bool isLoading;
  final String? error;

  TopCategoriesState({
    this.topCategories = const {},
    this.isLoading = false,
    this.error,
  });

  TopCategoriesState copyWith({
    Map<String, int>? topCategories,
    bool? isLoading,
    String? error,
  }) {
    return TopCategoriesState(
      topCategories: topCategories ?? this.topCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
