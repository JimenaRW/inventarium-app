import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_state.dart';

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
        title: const Text('Artículos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'CREAR\nARTÍCULO',
                  onTap: () => context.push('/articles/create'),
                ),
                _ActionButton(
                  icon: Icons.upload_file,
                  label: 'IMPORTAR\nCSV',
                  onTap: () => {},
                ),
                _ActionButton(
                  icon: Icons.save_alt,
                  label: 'EXPORTAR\nCSV',
                  onTap: () => context.push('/articles/exports-csv'),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ), // Espacio entre los botones y el buscador
            _buildSearchField(notifier),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(state)),
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

  Widget _buildContent(ArticleState state) {
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
                    onTap: () => _showArticleDetails(context, article, ref),
                  ),
                  DataCell(Text(article.stock.toString())),
                  DataCell(Text('\$${article.precio1?.toStringAsFixed(2)}')),
                ],
              );
            }).toList(),
      ),
    );
  }

  // void _navigateToDetail(BuildContext context, Article article) {
  //   context.push('/articles/${article.sku}');
  // }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

void _showArticleDetails(BuildContext context, Article article, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Agrega esta línea
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
                _buildDetailRow('Categoría', article.categoriaDescripcion!),
                _buildDetailRow(
                  'Código de Barras',
                  article.codigoBarras != null
                      ? article.codigoBarras!
                      : 'Sin Código de Barras',
                ),
                _buildDetailRow('Descripción', article.descripcion),
                _buildDetailRow('Fabricante', article.fabricante),
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
                _buildDetailRow('Ubicación', article.ubicacion),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/articles/edit/${article.id}').then((_) {
                          ref
                              .read(articleNotifierProvider.notifier)
                              .loadArticles();
                        });
                      },
                      child: const Text('Editar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: implementar pegue para borrar artículo en Firebase
                        Navigator.pop(context);
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ), // Agrega un poco de espacio extra al final
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
