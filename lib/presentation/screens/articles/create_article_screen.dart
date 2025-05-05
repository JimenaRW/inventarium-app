import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/widgets/article_form.dart';

class CreateArticleScreen extends ConsumerWidget {
  static const String name = 'create_article_screen';
  const CreateArticleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo artículo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ArticleForm(),
      ),
    );
  }
}
