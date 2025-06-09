import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/presentation/widgets/edit_article_form.dart';

class EditArticleScreen extends ConsumerStatefulWidget {
  static const String name = 'edit_article_screen';
  final String id;

  const EditArticleScreen({super.key, required this.id});

  @override
  ConsumerState<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends ConsumerState<EditArticleScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ref.read(articleNotifierProvider.notifier).loadArticleById(widget.id).then((
      _,
    ) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final articleState = ref.watch(articleNotifierProvider);
    final article = articleState.articles.firstWhereOrNull(
      (element) => element.id == widget.id,
    );

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar artículo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar artículo')),
        body: const Center(child: Text('Artículo no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar artículo')),
      body: ArticleEditForm(articleId: widget.id),
    );
  }
}
