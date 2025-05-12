import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/widgets/edit_article_form.dart';

class EditArticleScreen extends ConsumerStatefulWidget {
  static const String name = 'edit_article_screen';
  final String id;

  const EditArticleScreen({super.key, required this.id});

  @override
  ConsumerState<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends ConsumerState<EditArticleScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final articleState = ref.watch(articleNotifierProvider);
    final article = articleState.articles.firstWhere(
      (element) => element.id == widget.id,
    );

    if (article == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Artículo')),
      body: ArticleEditForm(article: article),
    );
  }
}
