import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_exports_csv_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_exports_csv_state%20.dart';
import 'package:inventarium/presentation/widgets/article_list_card.dart';

class ArticlesExportsCsv extends ConsumerStatefulWidget {
  static const String name = 'articles_exports_csv';
  const ArticlesExportsCsv({super.key});

  @override
  ConsumerState<ArticlesExportsCsv> createState() => _ArticlesExportsCsvState();
}

class _ArticlesExportsCsvState extends ConsumerState<ArticlesExportsCsv> {
  final _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleExportsCsvNotifierProvider.notifier).loadInitialData();
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.clear();
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ARTÍCULO',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),
                Text(
                  'Esta a punto de exportar ${state.exportedCount} artículos',
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _exportArticles(notifier),
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

                Expanded(child: _buildArticlesTable(state, notifier)),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
            notifier.searchArticles('');
          },
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
      ),
      onChanged: notifier.searchArticles,
    );
  }

  Widget _buildArticlesTable(
    ArticleExportsCsvState state,
    ArticleExportsCsvNotifier notifier,
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

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final metrics = scrollNotification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent * 0.9 &&
              metrics.axis == Axis.vertical) {
            if (state.hasMore) {
              notifier.loadMoreArticles();
            }
          }
        }
        return true;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount:
            state.filteredArticles.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.filteredArticles.length) {
            final article = state.filteredArticles[index];
            return GestureDetector(
              onTap: () => _showArticleDetails(context, article),
              child: ArticleListCard(
                article: article,
                showCheckbox: false,
                showImage: false,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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

  Future<void> _exportArticles(ArticleExportsCsvNotifier notifier) async {
    if (!mounted) return;

    setState(() => isLoading = true);

    await notifier.exportArticles();

    if (!mounted) return;

    setState(() => isLoading = false);

    final exportedCount = ref.watch(
      articleExportsCsvNotifierProvider.select((state) => state.exportedCount),
    );

    final lastExportedUrl = ref.watch(
      articleExportsCsvNotifierProvider.select(
        (state) => state.lastExportedCsvUrl,
      ),
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('¡Exportación exitosa!'),
            content: Text(
              'Los $exportedCount artículos se han exportado correctamente.',
            ),
            actions: [
              TextButton(
                onPressed:
                    lastExportedUrl != null
                        ? () async {
                          try {
                            if (Navigator.of(ctx).canPop()) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('Compartiendo archivo...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }

                            await notifier.shareFileWithDownload(
                              lastExportedUrl,
                            );

                            if (mounted && Navigator.of(ctx).canPop()) {
                              Navigator.of(ctx).pop(); // cerrar diálogo
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al compartir: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                        : null,
                child: const Text('Compartir'),
              ),
            ],
          ),
    );
  }
}
