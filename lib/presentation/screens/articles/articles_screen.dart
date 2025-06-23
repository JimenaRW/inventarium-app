import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';
import 'package:inventarium/domain/role.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/article_search_notifier.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
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
  // ignore: avoid_init_to_null
  ArticleStatus? _selectedStatus = null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (arguments?.containsKey('filter') ?? false) {
        _handleFilterArgument(arguments!['filter']);
      } else {
        ref.read(articleSearchNotifierProvider.notifier).loadInitialData();
      }
    });
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadCurrentUser();
    });
  }

  void _handleFilterArgument(dynamic filter) {
    switch (filter) {
      case 'no_stock':
        ref
            .read(articleSearchNotifierProvider.notifier)
            .searchArticlesByNoStock();
        break;
      case 'low_stock':
        ref
            .read(articleSearchNotifierProvider.notifier)
            .searchArticlesByLowStock(10);
        break;
    }
  }

  @override
  void dispose() {
    _searchController.clear();
    _searchController.dispose();
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
    final arguments = GoRouterState.of(context).extra as Map<String, dynamic>?;

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
                      onTap: () {
                        final currentContext = context;
                        final articleNotifier = ProviderScope.containerOf(
                          currentContext,
                        ).read(articleSearchNotifierProvider.notifier);

                        context.push('/articles/create');

                        articleNotifier.toggleDeleteMode(false);
                        articleNotifier.loadInitialData();
                        _searchController.clear();
                      },
                    ),
                  if (enableBotton)
                    _ActionButton(
                      icon: Icons.upload_file,
                      label: 'IMPORTAR\nCSV',
                      onTap: () async {
                        if (!mounted) return;

                        final currentContext = context;
                        final articleNotifier = ProviderScope.containerOf(
                          currentContext,
                        ).read(articleSearchNotifierProvider.notifier);

                        await context.push('/articles/import-csv');

                        if (mounted) {
                          articleNotifier.toggleDeleteMode(false);
                          articleNotifier.loadInitialData();
                          _searchController.clear();
                        }
                      },
                    ),
                  _ActionButton(
                    icon: Icons.save_alt,
                    label: 'EXPORTAR\nCSV',
                    onTap: () async {
                      final result = await context.push(
                        '/articles/exports-csv',
                      );
                      if (result == true) {
                        ref.invalidate(articleSearchProvider);
                        ref
                            .read(articleSearchProvider.notifier)
                            .toggleDeleteMode(false);
                        ref
                            .read(articleSearchProvider.notifier)
                            .loadInitialData();
                        _searchController.clear();
                      }
                    },
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (arguments == null ||
                    (arguments['filter'] != 'no_stock' &&
                        arguments['filter'] != 'low_stock')) ...[
                  Text('Filtrar por estado:'),
                  Row(
                    children: [
                      Radio<ArticleStatus?>(
                        value: null,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            ref
                                .read(articleSearchNotifierProvider.notifier)
                                .filterArticlesByStatus(value);
                          });
                        },
                      ),
                      const Text('Todos'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<ArticleStatus?>(
                        value: ArticleStatus.active,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            ref
                                .read(articleSearchNotifierProvider.notifier)
                                .filterArticlesByStatus(value);
                          });
                        },
                      ),
                      const Text('Activos'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<ArticleStatus?>(
                        value: ArticleStatus.inactive,
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            ref
                                .read(articleSearchNotifierProvider.notifier)
                                .filterArticlesByStatus(value);
                          });
                        },
                      ),
                      const Text('Inactivos'),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 5),
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
                  const SnackBar(
                    content: Text("Por favor verifica iniciar sesión"),
                  ),
                ),
        );
      }
    });

    final enableBotton =
        currentRol == UserRole.admin || currentRol == UserRole.editor;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    if (state.articlesDeleted.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Debe seleccionar un artículo a eliminar.",
                              ),
                            ),
                          );
                      }
                      return;
                    }
                    try {
                      await notifier.removeAllArticles();
                      await notifier.loadInitialData();
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                state.successMessage ?? 'Borrado masivo exitoso!',
                              ),
                            ),
                          );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(state.errorDeleted ?? e.toString()),
                            ),
                          );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_sharp),
                  tooltip: 'Confirmar borrado masivo',
                  padding: const EdgeInsets.all(12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text('Artículos encontrados: ${state.filteredArticles.length}'),
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
            final state = ref.watch(articleSearchNotifierProvider);
            final arguments =
                GoRouterState.of(context).extra as Map<String, dynamic>?;
            if (state.hasMore &&
                (arguments == null ||
                    (arguments['filter'] != 'no_stock' &&
                        arguments['filter'] != 'low_stock'))) {
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

  void _showArticleDetails(
    BuildContext context,
    Article article,
    WidgetRef ref,
  ) {
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
                    'Detalles del artículo',
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
                  _buildDetailRow('Categoría', article.categoryDescription!),
                  _buildDetailRow(
                    'Código de barras',
                    article.barcode != null
                        ? article.barcode!
                        : 'Sin código de barras',
                  ),
                  _buildDetailRow('Descripción', article.description),
                  _buildDetailRow('Fabricante', article.fabricator),
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
                  _buildDetailRow('Ubicación', article.location),
                  _buildDetailRow(
                    'Estado',
                    article.status == ArticleStatus.active.name
                        ? "Activo"
                        : "Inactivo",
                  ),
                  const SizedBox(height: 20),
                  Consumer(
                    builder: (context, ref, child) {
                      final deleteState = ref.watch(
                        articleDeleteNotifierProvider,
                      );

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              if (enableBotton)
                                ElevatedButton(
                                  onPressed:
                                      deleteState.isLoading
                                          ? null
                                          : () async {
                                            Navigator.pop(bc);
                                            final currentContext = context;
                                            final articleNotifier =
                                                ProviderScope.containerOf(
                                                  currentContext,
                                                ).read(
                                                  articleSearchNotifierProvider
                                                      .notifier,
                                                );

                                            await context.push(
                                              '/articles/edit/${article.id}',
                                            );

                                            articleNotifier.loadInitialData();
                                          },
                                  child: const Text('Editar'),
                                ),
                              if (enableBotton &&
                                  article.status == ArticleStatus.active.name)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed:
                                      deleteState.isLoading
                                          ? null
                                          : () async {
                                            final confirmed = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder: (ctx) {
                                                return Consumer(
                                                  builder: (
                                                    context,
                                                    ref,
                                                    child,
                                                  ) {
                                                    final dialogDeleteState =
                                                        ref.watch(
                                                          articleDeleteNotifierProvider,
                                                        );

                                                    return AlertDialog(
                                                      title: const Text(
                                                        '¿Eliminar artículo?',
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            '¿Estás seguro de querer eliminar este artículo?',
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          Text(
                                                            'Descripción: ${article.description}',
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          if (dialogDeleteState
                                                                  .errorMessage !=
                                                              null)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 8.0,
                                                                  ),
                                                              child: Text(
                                                                dialogDeleteState
                                                                    .errorMessage!,
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              dialogDeleteState
                                                                      .isLoading
                                                                  ? null
                                                                  : () =>
                                                                      Navigator.pop(
                                                                        ctx,
                                                                        true,
                                                                      ),
                                                          child:
                                                              dialogDeleteState
                                                                      .isLoading
                                                                  ? const CircularProgressIndicator(
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                  )
                                                                  : const Text(
                                                                    'Eliminar',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );

                                            if (confirmed == true) {
                                              await ref
                                                  .read(
                                                    articleDeleteNotifierProvider
                                                        .notifier,
                                                  )
                                                  .deleteArticle(article.id!);

                                              if (context.mounted) {
                                                final currentState = ref.read(
                                                  articleDeleteNotifierProvider,
                                                );
                                                if (currentState.success) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Artículo eliminado correctamente.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                  ref
                                                      .read(
                                                        articleSearchNotifierProvider
                                                            .notifier,
                                                      )
                                                      .loadInitialData();
                                                  Navigator.pop(bc);
                                                }
                                              }
                                            }
                                          },
                                  child:
                                      deleteState.isLoading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text('Eliminar'),
                                ),
                            ],
                          ),
                          if (deleteState.isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      );
                    },
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
