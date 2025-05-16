import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/no_stock_notifier';
import 'package:inventarium/presentation/viewmodels/article/states/no_stock_state.dart';

// Define el Provider para el Notifier
final noStockProvider =
    AsyncNotifierProvider<NoStockArticlesNotifier, NoStockArticlesState>(
      () => NoStockArticlesNotifier(),
    );
