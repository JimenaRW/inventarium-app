
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
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
  bool _searchInList = false;

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
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _exportArticles(context, notifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text('CONTINUAR', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Text('Esta a punto de exportar ${state.filteredArticles.length} artículos'),
            
            Row(
              children: [
                Checkbox(
                  value: _searchInList,
                  onChanged: (value) => setState(() => _searchInList = value ?? false),
                ),
                const Text('Buscar en la lista'),
              ],
            ),
            
            const Divider(),
            
            Expanded(
              child: _buildArticlesTable(state),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesTable(ArticleState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.filteredArticles.isEmpty) {
      return const Center(child: Text('No se encontraron artículos'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Stock'), numeric: true),
          DataColumn(label: Text('Precio1'), numeric: true),
        ],
        rows: state.filteredArticles.map((article) {
          return DataRow(
            cells: [
              DataCell(Text(article.sku)),
              DataCell(Text(article.descripcion)),
              DataCell(Text(article.stock.toString())),
              DataCell(Text('\$${article.precio1?.toStringAsFixed(2)}')),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _exportArticles(BuildContext context, ArticleNotifier notifier) {
    // Lógica para exportar los artículos
    notifier.exportArticles().then((_) {
      context.pushNamed(ArticlesShareCsv.name);
    });
  }
}