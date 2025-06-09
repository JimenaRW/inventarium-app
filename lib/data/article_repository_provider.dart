import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_state.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;

Provider<ArticleRepository> articleRepositoryProvider =
    Provider<ArticleRepository>((ref) => ArticleRepository(db, storage));

final articleNotifierProvider =
    StateNotifierProvider<ArticleNotifier, ArticleState>(
      (ref) => ArticleNotifier(
        ref.read(articleRepositoryProvider),
        ref.read(categoryRepositoryProvider),
      ),
    );

final articleSearchNotifierProvider =
    StateNotifierProvider<ArticleSearchNotifier, ArticleSearchState>((ref) {
      final articleNotifier = ref.watch(articleNotifierProvider.notifier);
      return ArticleSearchNotifier(articleNotifier);
    });
