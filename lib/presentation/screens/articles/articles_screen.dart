import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';

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
      ref.read(articleSearchNotifierProvider.notifier).loadInitialData();
      ref.read(articleSearchNotifierProvider.notifier).toggleDeleteMode(false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleSearchNotifierProvider);
    final notifier = ref.read(articleSearchNotifierProvider.notifier);

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
                  onTap:
                      () => {
                        context.push('/articles/create'),
                        ref
                            .read(articleSearchNotifierProvider.notifier)
                            .toggleDeleteMode(false),
                      },
                ),
                _ActionButton(
                  icon: Icons.upload_file,
                  label: 'IMPORTAR\nCSV',
                  onTap:
                      () => {
                        context.push('/articles/import-csv'),
                        ref
                            .read(articleSearchNotifierProvider.notifier)
                            .toggleDeleteMode(false),
                      },
                ),
                _ActionButton(
                  icon: Icons.save_alt,
                  label: 'EXPORTAR\nCSV',
                  onTap:
                      () => {
                        context.push('/articles/exports-csv'),
                        ref
                            .read(articleSearchNotifierProvider.notifier)
                            .toggleDeleteMode(false),
                      },
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ), // Espacio entre los botones y el buscador
            _buildSearchField(notifier, state),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(
    ArticleSearchNotifier notifier,
    ArticleSearchState state,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 64,
      ), // Ensure minimum tap target size
      child: Row(
        children: [
          Expanded(
            // This ensures the TextField has a bounded width
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por SKU o descripción',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      notifier.searchArticles('');
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true, // Reduces the default padding
                ),
                onChanged: notifier.searchArticles,
              ),
            ),
          ),
          if (!state.isDeleted) ...[
            IconButton(
              onPressed: () => notifier.toggleDeleteMode(true),
              icon: const Icon(Icons.delete_outline_outlined),
              tooltip: 'Borrado masivo',
              padding: const EdgeInsets.all(12),
            ),
          ],
          if (state.isDeleted) ...[
            IconButton(
              onPressed: () => notifier.toggleDeleteMode(false),
              icon: const Icon(Icons.cancel_outlined),
              tooltip: 'Cancelar',
              padding: const EdgeInsets.all(12),
            ),
            IconButton(
              // onPressed: () async => await removeArticles(notifier, scaffoldMessenger),
              onPressed: () async {
                try {
                  await notifier.removeAllArticles();
                  await notifier.loadInitialData();
                  // Mostrar mensaje de éxito
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(state.successMessage!)),
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(articleSearchNotifierProvider.notifier)
                        .loadInitialData();
                  });
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorDeleted != null
                            ? state.errorDeleted!
                            : e.toString(),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_sharp),
              tooltip: 'Confirmar borrado masivo',
              padding: const EdgeInsets.all(12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(
    ArticleSearchState state,
    ArticleSearchNotifier notifier,
  ) {
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
              onPressed: () => notifier.loadInitialData(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.filteredArticles.isEmpty) {
      return const Center(child: Text('No se encontraron artículos'));
    }

    print('Artículos en filteredArticles: ${state.filteredArticles.length}');

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final metrics = scrollNotification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent * 0.9 &&
              metrics.axis == Axis.vertical) {
            print('Llegó cerca del final de la lista...');
            if (state.hasMore) {
              print('Cargando más artículos...');
              notifier.loadMoreArticles();
            }
          }
        }
        return true;
      },
      child: ListView(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                if (state.isDeleted) DataColumn(label: Text('')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Descripción')),
                DataColumn(label: Text('Stock'), numeric: true),
                DataColumn(label: Text('Precio1'), numeric: true),
              ],
              rows:
                  state.filteredArticles.map((article) {
                    return DataRow(
                      cells: [
                        if (state.isDeleted)
                          DataCell(
                            Checkbox(
                              value: state.articlesDeleted.contains(article.id),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    notifier.toggleDeleteList(
                                      true,
                                      article.id!,
                                    );
                                  } else {
                                    notifier.toggleDeleteList(
                                      false,
                                      article.id!,
                                    );
                                  }
                                });
                                print(state.articlesDeleted);
                              },
                            ),
                          ),
                        DataCell(Text(article.sku)),
                        DataCell(
                          Text(article.descripcion),
                          onTap: () {
                            print(
                              article,
                            ); // Verifica si el artículo es null o no
                            _showArticleDetails(context, article, ref);
                          },
                        ),
                        DataCell(Text(article.stock.toString())),
                        DataCell(
                          Text('\$${article.precio1?.toStringAsFixed(2)}'),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
          if (state.isLoadingMore)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

Future<void> _showDeleteConfirmation(
  BuildContext context,
  ArticleSearchNotifier notifier,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Confirmar eliminado masivo'),
          content: const Text(
            '¿Estás seguro de querer eliminar los artículos seleccinados?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
  );

  if (confirmed == true) {
    await notifier.removeAllArticles();
  }
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
  print('Artículo:');
  print('ID: ${article.id}');
  print('SKU: ${article.sku}');
  print('Categoría: ${article.categoriaDescripcion}');
  print('Código de Barras: ${article.codigoBarras}');
  print('Descripción: ${article.descripcion}');
  print('Fabricante: ${article.fabricante}');
  print('IVA: ${article.iva}');
  print('Precio 1: ${article.precio1}');
  print('Precio 2: ${article.precio2}');
  print('Precio 3: ${article.precio3}');
  print('Stock: ${article.stock}');
  print('Ubicación: ${article.ubicacion}');
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
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Image.network(
                      article.imageUrl!,
                      fit: BoxFit.contain,
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
                        Navigator.pop(bc);
                        context.push('/articles/edit/${article.id}').then((_) {
                          ref
                              .read(articleSearchNotifierProvider.notifier)
                              .loadInitialData();
                        });
                        ref
                            .read(articleSearchNotifierProvider.notifier)
                            .toggleDeleteMode(false);
                      },
                      child: const Text('Editar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(bc);
                        context.push('/articles/delete/${article.id}').then((
                          _,
                        ) {
                          ref
                              .read(articleSearchNotifierProvider.notifier)
                              .loadInitialData();
                        });

                        ref
                            .read(articleSearchNotifierProvider.notifier)
                            .toggleDeleteMode(false);
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
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
