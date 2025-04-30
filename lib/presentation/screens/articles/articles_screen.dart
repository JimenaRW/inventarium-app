import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/provider.dart';
import 'package:inventarium/presentation/viewmodels/states/article_search_state.dart';

class ArticlesScreen extends ConsumerStatefulWidget {
  static const String name = 'articles_screen';
  const ArticlesScreen({super.key});

  @override
  ConsumerState<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends ConsumerState<ArticlesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleSearchProvider.notifier).loadArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleSearchProvider);
    final notifier = ref.read(articleSearchProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Artículos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: articlesTable(notifier, state),
      ),
      // Botón flotante para crear nuevo artículo
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/articles/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Column articlesTable(
    ArticleSearchNotifier notifier,
    ArticleSearchState state,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por SKU o descripción',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                },
              ),
            ),
            onChanged: notifier.setSearchQuery,
          ),
        ),
        Expanded(child: _buildContent(state, notifier.filteredArticles)),
      ],
    );
  }

  Widget _buildContent(
    ArticleSearchState state,
    List<Article> filteredArticles,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    if (filteredArticles.isEmpty) {
      return const Center(child: Text('No se encontraron artículos'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Stock'), numeric: true),
          DataColumn(label: Text('Precio1'), numeric: true),
        ],
        rows:
            filteredArticles.map((article) {
              return DataRow(
                cells: [
                  DataCell(Text(article.sku)),
                  DataCell(Text(article.descripcion)),
                  DataCell(Text(article.stockInicial.toString())),
                  DataCell(Text('\$${article.precio1?.toStringAsFixed(2)}')),
                ],
              );
            }).toList(),
      ),
    );
  }
}
