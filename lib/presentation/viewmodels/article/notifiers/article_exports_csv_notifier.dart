import 'dart:io';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/data/category_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_exports_csv_state%20.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ArticleExportsCsvNotifier extends StateNotifier<ArticleExportsCsvState> {
  final ArticleRepository _repository;
  final CategoryRepository _repositoryCategories;

  ArticleExportsCsvNotifier(this._repository, this._repositoryCategories)
    : super(const ArticleExportsCsvState());

  Future<void> loadArticles() async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await _repository.getArticles();
      final categories = await _repositoryCategories.getAllCategories();

      final updatedArticles =
          articles.map((article) {
            final categoriaDescripcion =
                categories
                    .firstWhereOrNull((x) => x.id.contains(article.categoria))
                    ?.descripcion;

            return article.copyWith(categoriaDescripcion: categoriaDescripcion);
          }).toList();

      state = state.copyWith(
        articles: updatedArticles,
        filteredArticles: updatedArticles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar artículos: ${e.toString()}',
      );
    }
  }

  void setSearchQuery(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered =
        state.articles.where((article) {
          return article.sku.toLowerCase().contains(lowerQuery) ||
              article.descripcion.toLowerCase().contains(lowerQuery) ||
              (article.codigoBarras != null &&
                  article.codigoBarras!.toLowerCase().contains(lowerQuery));
        }).toList();

    state = state.copyWith(searchQuery: query, filteredArticles: filtered);
  }

  Future<List<Article>> getArticles({int page = 1, int limit = 20}) async {
    try {
      final articles = await _repository.getArticlesPaginado(
        page: page,
        limit: limit,
      );
      return articles;
    } catch (e) {
      throw Exception('Error al cargar artículos: ${e.toString()}');
    }
  }

  Future<void> exportArticles() async {
    try {
      state = state.copyWith(isLoading: true);

      String url = await _repository.exportArticles();

      state = state.copyWith(isLoading: false, lastExportedCsvUrl: url, exportedCount: state.articles.length);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }


Future<void> shareFileWithDownload(String storagePath) async {

 try {
    // final doc =  convertPublicUrlToGsUrl(storagePath);
    // final ref = FirebaseStorage.instance.ref('https://firebasestorage.googleapis.com/v0/b/inventarium-th3-2025.firebasestorage.app/o/exports_csv%2FC7hAYluK3BcEcDEpL2e0WEhs8j42%2Farticulos_export_1747360026725.csv?alt=media&token=22b634ae-6672-4aad-b29f-720a0112ee2e');
    // final bytes = await ref.getData();

    // if (bytes == null) {
    //   print("No se pudo descargar el archivo.");
    //   return;
    // }
    final response = await http.get(Uri.parse(storagePath));

    // Obtener directorio temporal
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/documento.csv');

    // Guardar archivo temporal
    await tempFile.writeAsBytes(response.bodyBytes);

    // Compartir archivo
    await Share.shareXFiles([XFile(tempFile.path)], text: 'Compartir archivo');

  } catch (e) {
    print("Error al compartir archivo: $e");
  }
} 

String convertPublicUrlToGsUrl(String publicUrl) {
  final uri = Uri.parse(publicUrl);
  final bucket = 'inventarium-th3-2025.appspot.com';
  final objectPath = Uri.decodeFull(uri.pathSegments[4]); // exports_csv/.../archivo.csv
  return 'gs://$bucket/$objectPath';
} 



}
