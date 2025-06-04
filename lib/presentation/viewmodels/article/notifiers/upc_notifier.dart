import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/upc_repository.dart';
import 'package:inventarium/presentation/viewmodels/article/states/upc_state.dart';

final upcNotifierProvider = StateNotifierProvider<UPCNotifier, UPCState>((ref) {
  return UPCNotifier();
});

class UPCNotifier extends StateNotifier<UPCState> {
  final UPCRepository _repository = UPCRepositoryImpl();

  UPCNotifier() : super(const UPCState());

  Future<String?> scanUPC(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _repository.scanUPC(context);
      state = state.copyWith(scanResult: result, isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }
}
