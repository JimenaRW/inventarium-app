import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';

class StockScreen extends ConsumerStatefulWidget {
  static const String name = 'stock_screen';
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleSearchNotifierProvider.notifier).loadInitialData();
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
        title: const Text('Stock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(notifier),
            const SizedBox(height: 16),
            Expanded(
              child:
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                      ? _buildError(state.error!, notifier)
                      : state.filteredArticles.isEmpty
                      ? const Center(child: Text('No se encontraron artículos'))
                      : _buildList(state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ArticleSearchNotifier notifier) {
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
      ),
      onChanged: notifier.searchArticles,
    );
  }

  Widget _buildError(String error, ArticleSearchNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: notifier.loadInitialData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ArticleSearchState state, ArticleSearchNotifier notifier) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final metrics = scrollNotification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent * 0.9 &&
              metrics.axis == Axis.vertical) {
            if (state.hasMore) notifier.loadMoreArticles();
          }
        }
        return true;
      },
      child: ListView.builder(
        itemCount:
            state.filteredArticles.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.filteredArticles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final article = state.filteredArticles[index];
          return _ArticleCard(article: article, notifier: notifier);
        },
      ),
    );
  }
}

class _ArticleCard extends ConsumerStatefulWidget {
  final Article article;
  final ArticleSearchNotifier notifier;

  const _ArticleCard({required this.article, required this.notifier});

  @override
  ConsumerState<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends ConsumerState<_ArticleCard> {
  late TextEditingController _stockController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: widget.article.stock.toString(),
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  void _saveStock() {
    final newStock =
        int.tryParse(_stockController.text) ?? widget.article.stock;
    widget.notifier.updateStock(widget.article.id!, newStock);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.article.descripcion,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('SKU: ${widget.article.sku}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _editing
                    ? SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                    : Text('Stock: ${widget.article.stock}'),
                _editing
                    ? Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: _saveStock,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _editing = false),
                        ),
                      ],
                    )
                    : IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => setState(() => _editing = true),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
