class UPCState {
  final String scanResult;
  final bool isLoading;
  final String? error;

  const UPCState({this.scanResult = '', this.isLoading = false, this.error});

  UPCState copyWith({String? scanResult, bool? isLoading, String? error}) {
    return UPCState(
      scanResult: scanResult ?? this.scanResult,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
