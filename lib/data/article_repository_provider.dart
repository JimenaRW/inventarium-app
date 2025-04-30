import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';

Provider<ArticleRepository> articleRepositoryProvider = Provider<ArticleRepository>(
  (ref) => ArticleRepository(),
);