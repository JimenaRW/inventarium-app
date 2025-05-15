import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/screens/articles/articles_share_csv.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_state.dart';

class ArticlesExportsCsv extends ConsumerStatefulWidget {
  static const String name = 'articles_exports_csv';
  const ArticlesExportsCsv({super.key});

  @override
  ConsumerState<ArticlesExportsCsv> createState() => _ArticlesExportsCsvState();
}

class _ArticlesExportsCsvState extends ConsumerState<ArticlesExportsCsv> {
  final _searchController = TextEditingController();
  bool _searchInList = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleNotifierProvider.notifier).loadArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleNotifierProvider);
    final notifier = ref.read(articleNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Master'),
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
            // Sección de confirmación de exportación
            const Text(
              'ARTÍCULO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿ESTA SEGURO?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Botones de acción para exportación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _exportArticles(context, notifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(120, 50),
                  ),

                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Esta a punto de exportar ${state.articles.length} artículos',
            ),

            // Opción de búsqueda en lista
            Row(
              children: [
                Checkbox(
                  value: _searchInList,
                  onChanged:
                      (value) => setState(() => _searchInList = value ?? false),
                ),
                const Text('Buscar en la lista'),
              ],
            ),

            const Divider(),

            // Campo de búsqueda (similar a articles_screen)
            _buildSearchField(notifier),
            const SizedBox(height: 16),

            // Listado de artículos (similar a articles_screen pero sin botones)
            Expanded(child: _buildArticlesTable(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ArticleNotifier notifier) {
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

  Widget _buildArticlesTable(ArticleState state) {
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
          DataColumn(label: Text('Precio1'), numeric: true),
        ],
        rows:
            state.filteredArticles.map((article) {
              return DataRow(
                cells: [
                  DataCell(Text(article.sku)),
                  DataCell(
                    Text(article.descripcion),
                    onTap: () => _showArticleDetails(context, article),
                  ),
                  DataCell(Text(article.stock.toString())),
                  DataCell(Text('\$${article.precio1?.toStringAsFixed(2)}')),
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
                    'Detalles del Artículo',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow('SKU', article.sku),
                  _buildDetailRow(
                    'Categoría',
                    article.categoriaDescripcion ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Código de Barras',
                    article.codigoBarras ?? 'Sin Código de Barras',
                  ),
                  _buildDetailRow('Descripción', article.descripcion),
                  _buildDetailRow('Fabricante', article.fabricante ?? 'N/A'),
                  _buildDetailRow('IVA', article.iva.toString()),
                  _buildDetailRow(
                    'Precio 1',
                    '\$${article.precio1?.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Precio 2',
                    '\$${article.precio2?.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Precio 3',
                    '\$${article.precio3?.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow('Stock', article.stock.toString()),
                  _buildDetailRow('Ubicación', article.ubicacion ?? 'N/A'),
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

  void _exportArticles(BuildContext context, ArticleNotifier notifier) {
    notifier.exportArticles().then((_) {
      context.pushNamed(ArticlesShareCsv.name);
    });
  }
}
