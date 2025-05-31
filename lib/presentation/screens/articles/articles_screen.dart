import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/states/article_search_state.dart';
import 'package:inventarium/presentation/viewmodels/users/provider.dart';
import 'package:inventarium/presentation/widgets/article_list_card.dart';

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
      final state = GoRouterState.of(context);
      final arguments = state.extra as Map<String, dynamic>?;
      if (arguments != null && arguments['filter'] != null) {
        switch (arguments['filter']) {
          case 'no_stock':
            ref
                .read(articleSearchNotifierProvider.notifier)
                .searchArticlesByNoStock();
            break;
          case 'low_stock':
            ref
                .read(articleSearchNotifierProvider.notifier)
                .searchArticlesByLowStock(10); // Umbral de stock bajo
            break;
        }
      } else {
        ref.read(articleSearchNotifierProvider.notifier).loadInitialData();
      }
    });
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadCurrentUser();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleSearchNotifierProvider);
    final notifier = ref.read(articleSearchNotifierProvider.notifier);
    final userState = ref.read(userNotifierProvider);
    final currentRol = userState.user?.role;
    final enableBotton =
        currentRol == UserRole.admin || currentRol == UserRole.editor;

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
            if (enableBotton)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (enableBotton)
                    _ActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'CREAR\nARTÍCULO',
                      onTap:
                          () => {
                            context.push('/articles/create'),
                            ref
                                .read(articleSearchNotifierProvider.notifier)
                                .toggleDeleteMode(false),
                            ref
                                .read(articleSearchNotifierProvider.notifier)
                                .loadInitialData(),
                            _searchController.clear(),
                          },
                    ),
                  if (enableBotton)
                    _ActionButton(
                      icon: Icons.upload_file,
                      label: 'IMPORTAR\nCSV',
                      onTap:
                          () => {
                            context.push('/articles/import-csv'),
                            ref
                                .read(articleSearchNotifierProvider.notifier)
                                .toggleDeleteMode(false),
                            ref
                                .read(articleSearchNotifierProvider.notifier)
                                .loadInitialData(),
                            _searchController.clear(),
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
                          ref
                              .read(articleSearchNotifierProvider.notifier)
                              .loadInitialData(),
                          _searchController.clear(),
                        },
                  ),
                ],
              ),
            const SizedBox(height: 24),
            _buildSearchField(notifier, state, currentRol),
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
    UserRole? currentRol,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        FirebaseAuth.instance.signOut().then(
          (value) =>
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(content: Text("Por favor verifica iniciar sesión")),
                ),
        );
      }
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final enableBotton =
        currentRol == UserRole.admin || currentRol == UserRole.editor;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Row(
        children: [
          Expanded(
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
                  isDense: true,
                ),
                onChanged: notifier.searchArticles,
              ),
            ),
          ),

          if (!state.isDeleted && enableBotton) ...[
            if (enableBotton)
              IconButton(
                onPressed: () => notifier.toggleDeleteMode(true),
                icon: const Icon(Icons.delete_outline_outlined),
                tooltip: 'Borrado masivo',
                padding: const EdgeInsets.all(12),
              ),
          ],
          if (state.isDeleted && enableBotton) ...[
            IconButton(
              onPressed: () => notifier.toggleDeleteMode(false),
              icon: const Icon(Icons.cancel_outlined),
              tooltip: 'Cancelar',
              padding: const EdgeInsets.all(12),
            ),
            IconButton(
              onPressed: () async {
                try {
                  if (state.articlesDeleted.isNotEmpty) {
                    await notifier.removeAllArticles();
                    await notifier.loadInitialData();
                    // Mostrar mensaje de éxito
                    scaffoldMessenger.clearSnackBars();
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(state.successMessage!)),
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref
                          .read(articleSearchNotifierProvider.notifier)
                          .loadInitialData();
                    });
                  } else {
                    scaffoldMessenger.clearSnackBars();
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Debe selecionar un artículo a eliminar.",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  scaffoldMessenger.clearSnackBars();
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
              onTap: () => _showArticleDetails(context, article, ref),
              child: ArticleListCard(
                article: article,
                showCheckbox: state.isDeleted,
                checkboxValue: state.articlesDeleted.contains(article.id),
                onCheckboxChanged: (value) {
                  notifier.toggleDeleteList(value ?? false, article.id!);
                },
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
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
  final userState = ref.read(userNotifierProvider);
  final currentRol = userState.user?.role;
  final enableBotton =
      currentRol == UserRole.admin || currentRol == UserRole.editor;

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
                  // ignore: sized_box_for_whitespace
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
                    if (enableBotton)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(bc);
                          context.push('/articles/edit/${article.id}').then((
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
                        child: const Text('Editar'),
                      ),
                    if (enableBotton)
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            softWrap: true,
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    ),
  );
}
