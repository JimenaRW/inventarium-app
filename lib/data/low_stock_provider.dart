import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/low_stock_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/low_stock_state.dart';

final lowStockProvider = AutoDisposeAsyncNotifierProvider<
  LowStockArticlesNotifier,
  LowStockArticlesState
>(() => LowStockArticlesNotifier());
