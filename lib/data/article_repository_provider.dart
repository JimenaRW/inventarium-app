import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_state.dart';

late final FirebaseFirestore db;

Provider<ArticleRepository> articleRepositoryProvider = Provider<ArticleRepository>(
  (ref) => ArticleRepository(db),
);

StateNotifierProvider<ArticleNotifier, ArticleState> articleNotifierProvider = StateNotifierProvider<ArticleNotifier, ArticleState>(
  (ref) => ArticleNotifier(ref.read(articleRepositoryProvider)),
);