import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/screens/articles/articles_share_csv.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_exports_csv_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_exports_csv_state%20.dart';

class ArticlesExportsCsv extends ConsumerStatefulWidget {
  static const String name = 'articles_exports_csv';
  const ArticlesExportsCsv({super.key});

  @override
  ConsumerState<ArticlesExportsCsv> createState() => _ArticlesExportsCsvState();
}

class _ArticlesExportsCsvState extends ConsumerState<ArticlesExportsCsv> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleExportsCsvNotifierProvider.notifier).loadArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleExportsCsvNotifierProvider);
    final notifier = ref.read(articleExportsCsvNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar master'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ARTÍCULO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            Text('Esta a punto de exportar ${state.articles.length} artículos'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _exportFile(context, notifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'GENERAR REPORTE',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),

            _buildSearchField(notifier),
            const SizedBox(height: 16),

            Expanded(child: _buildArticlesTable(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ArticleExportsCsvNotifier notifier) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar por SKU o descripción',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            notifier.setSearchQuery('');
          },
        ),
      ),
      onChanged: notifier.setSearchQuery,
    );
  }

  Widget _buildArticlesTable(ArticleExportsCsvState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () =>
                      ref.read(articleNotifierProvider.notifier).loadArticles(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.filteredArticles.isEmpty) {
      return const Center(child: Text('No se encontraron artículos'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Stock'), numeric: true),
          DataColumn(label: Text('Precio 1'), numeric: true),
        ],
        rows:
            state.filteredArticles.map((article) {
              return DataRow(
                cells: [
                  DataCell(Text(article.sku)),
                  DataCell(
                    Text(article.description),
                    onTap: () => _showArticleDetails(context, article),
                  ),
                  DataCell(Text(article.stock.toString())),
                  DataCell(Text('\$${article.price1?.toStringAsFixed(2)}')),
                ],
              );
            }).toList(),
      ),
    );
  }

  void _showArticleDetails(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Wrap(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detalles del artículo',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow('SKU', article.sku),
                  _buildDetailRow(
                    'Categoría',
                    article.categoryDescription ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Código de barras',
                    article.barcode ?? 'Sin código de barras',
                  ),
                  _buildDetailRow('Descripción', article.description),
                  _buildDetailRow(
                    'Fabricante',
                    article.fabricator.isEmpty ? article.fabricator : 'N/A',
                  ),
                  _buildDetailRow('IVA', article.iva.toString()),
                  _buildDetailRow(
                    'Precio 1',
                    '\$${article.price1?.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Precio 2',
                    '\$${article.price2?.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Precio 3',
                    '\$${article.price3?.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow('Stock', article.stock.toString()),
                  _buildDetailRow(
                    'Ubicación',
                    article.location.isEmpty ? article.location : 'N/A',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _exportArticles(
    BuildContext context,
    ArticleExportsCsvNotifier notifier,
  ) {
    notifier.exportArticles().then((_) {
      // ignore: use_build_context_synchronously
      context.pushNamed(ArticlesShareCsv.name);
    });
  }

  void _exportFile(BuildContext context, ArticleExportsCsvNotifier notifier) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Generar reporte'),
            content: Text(
              '¿Estar seguro de querer exportar la totalidad de los artículos?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => _exportArticles(ctx, notifier),
                child: const Text('Compartir'),
              ),
            ],
          ),
    );
  }
}
