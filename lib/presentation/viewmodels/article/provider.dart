import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_create_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_create_state.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';


final articleCreateProvider = StateNotifierProvider.autoDispose<ArticleCreateNotifier, ArticleCreateState>(
  (ref) => ArticleCreateNotifier(
    ref.read(articleNotifierProvider.notifier),
  ),
);

final articleSearchProvider = StateNotifierProvider.autoDispose<ArticleSearchNotifier, ArticleSearchState>(
  (ref) => ArticleSearchNotifier(
    ref.read(articleNotifierProvider.notifier),
  ),
);

