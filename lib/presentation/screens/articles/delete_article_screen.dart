import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';

class DeleteArticleScreen extends ConsumerWidget {
  final String articleId;
  static const String name = 'delete_article_screen';

  const DeleteArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleState = ref.watch(articleDeleteNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar Artículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de querer eliminar este artículo?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('ID del artículo: $articleId'),
            const SizedBox(height: 16),

            if (articleState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  articleState.errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      articleState.isLoading
                          ? null
                          : () {
                            ref
                                .read(articleDeleteNotifierProvider.notifier)
                                .deleteArticle(articleId);
                          },
                  child:
                      articleState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Eliminar'),
                ),
              ],
            ),

            if (articleState.success)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Artículo eliminado correctamente.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
