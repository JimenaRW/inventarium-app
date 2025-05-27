import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:inventarium/data/article_repository.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_image_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ArticleImageNotifier extends StateNotifier<ArticleImageState> {
  final ArticleRepository _repository;

  ArticleImageNotifier(this._repository) : super(const ArticleImageState());

  Future<void> uploadImage(File image, String sku) async {
    state = state.copyWith(isLoading: true);
    try {
      final imageUrl = await _repository.uploadArticleImage(image, sku);
      print('Image URL: $imageUrl');
      state = state.copyWith(
        isLoading: false,
        imageUrl: imageUrl,
        success: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> shareImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/image.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(tempFile.path)], text: 'Compartir imagen');
    } catch (e) {
      print("Error al compartir imagen: $e");
    }
  }

  void resetState() {
    state = const ArticleImageState();
  }
}
