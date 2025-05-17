import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_create_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_exports_csv_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_import_csv_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_update_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_create_state.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_exports_csv_state%20.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_import_csv_state.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_update_state.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;

final articleCreateProvider = StateNotifierProvider.autoDispose<
  ArticleCreateNotifier,
  ArticleCreateState
>((ref) => ArticleCreateNotifier(ref.read(articleNotifierProvider.notifier)));

final articleSearchProvider = StateNotifierProvider.autoDispose<
  ArticleSearchNotifier,
  ArticleSearchState
>((ref) => ArticleSearchNotifier(ref.read(articleNotifierProvider.notifier)));

final articleUpdateProvider = StateNotifierProvider.autoDispose<
  ArticleUpdateNotifier,
  ArticleUpdateState>(
  (ref) => ArticleUpdateNotifier(ref.read(articleRepositoryProvider), ref),
); // ¡Pasa 'ref' aquí!

Provider<ArticleRepository> articleRepositoryProvider =
    Provider<ArticleRepository>((ref) => ArticleRepository(db, storage));

final articleExportsCsvNotifierProvider =
    StateNotifierProvider<ArticleExportsCsvNotifier, ArticleExportsCsvState>(
      (ref) => ArticleExportsCsvNotifier(
        ref.read(articleRepositoryProvider),
        ref.read(categoryRepositoryProvider),
      ),
    );


final articleImportCsvNotifierProvider =
  StateNotifierProvider<ArticleImportCsvNotifier, ArticleImportCsvState>(
      (ref) => ArticleImportCsvNotifier(
        ref.read(articleRepositoryProvider),
        ref.read(categoryRepositoryProvider),
      ),
    );