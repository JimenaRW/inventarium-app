import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/notifiers/article_form_notifier.dart';
import 'package:inventarium/presentation/viewmodels/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/states/article_form_state.dart';
import 'package:inventarium/presentation/viewmodels/states/article_search_state.dart';

final articleFormNotifierProvider = StateNotifierProvider.autoDispose<
    ArticleFormNotifier, ArticleFormState>(
  (ref) {
  final repository = ref.read(articleRepositoryProvider);
  return ArticleFormNotifier(repository);
});

final articleSearchProvider = StateNotifierProvider.autoDispose<ArticleSearchNotifier, ArticleSearchState>(
  (ref) {
    final repository = ref.read(articleRepositoryProvider);
    return ArticleSearchNotifier(repository);
  },
);