import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/screens/articles/_article_form.dart';

class ArticleCreateScreen extends ConsumerWidget {
  static const String name = 'article_create_screen';
  const ArticleCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Artículo'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ArticleForm(),
      ),
    );
  }
}