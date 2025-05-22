class CategoryDeleteState {
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  CategoryDeleteState({
    required this.isLoading,
    this.errorMessage,
    required this.success,
  });

  // Define un constructor de copia para modificar solo las propiedades necesarias
  CategoryDeleteState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return CategoryDeleteState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      success: success ?? this.success,
    );
  }
}
