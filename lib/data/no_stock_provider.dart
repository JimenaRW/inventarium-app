import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/no_stock_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/no_stock_state.dart';

// Define el Provider para el Notifier con autoDispose
final noStockProvider = AutoDisposeAsyncNotifierProvider<
  NoStockArticlesNotifier,
  NoStockArticlesState
>(() => NoStockArticlesNotifier());
