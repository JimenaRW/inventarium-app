import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/total_articles_notifier.dart';

final allArticlesProvider =
    AutoDisposeAsyncNotifierProvider<AllArticlesNotifier, int>(
      () => AllArticlesNotifier(),
    );