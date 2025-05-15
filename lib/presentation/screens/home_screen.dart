import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/core/menu/drawer_menu.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String name = 'home_screen';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleSearchProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda si es necesario
            },
          ),
        ],
      ),
      drawer: DrawerMenu(scaffoldKey: widget.scaffoldKey),
      // body: InfiniteScrollTable<Article>(
      //   items: state.articles,
      //   isLoading: state.isLoading,
      //   isLoadingMore: state.isLoadingMore,
      //   hasMore: state.hasMore,
      //   onLoadMore: notifier.loadMoreArticles,
      //   onSearch: notifier.searchArticles,
      //   searchHintText: 'Buscar artículos...',
      //   showEditDeleteButtons: true, // Habilitar botones de edición/eliminación
      //   onMassDelete: (articles) {},
      //   columns: const [
      //     DataColumn(label: Text('SKU')),
      //     DataColumn(label: Text('Descripción')),
      //     DataColumn(label: Text('Stock'), numeric: true),
      //     DataColumn(label: Text('Precio1'), numeric: true),
      //   ],
      //   buildRow: (article) => DataRow(
      //     cells: [
      //       DataCell(Text(article.sku)),
      //       DataCell(
      //         Text(article.descripcion),
      //         onTap: () => _showArticleDetails(context, article, ref),
      //       ),
      //       DataCell(Text(article.stock.toString())),
      //       DataCell(Text('\$${article.precio1?.toStringAsFixed(2)}')),
      //     ],
      //   ),
      //   detailViewBuilder: (context, ref, article) {
      //     return _buildArticleDetails(context, ref, article);
      //   },
      // ),
    );
  }

//   void _showArticleDetails(BuildContext context, Article article, WidgetRef ref) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => _buildArticleDetails(context, ref, article),
//     );
//   }

//   Widget _buildArticleDetails(BuildContext context, WidgetRef ref, Article article) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       child: Wrap(
//         children: <Widget>[
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Detalles del Artículo',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               _buildDetailRow('SKU', article.sku),
//               _buildDetailRow('Descripción', article.descripcion),
//               _buildDetailRow('Stock', article.stock.toString()),
//               _buildDetailRow(
//                 'Precio 1',
//                 '\$${article.precio1?.toStringAsFixed(2)}',
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       context.push('/articles/edit/${article.id}').then((_) {
//                         ref.read(articleSearchProvider.notifier).loadInitialData();
//                       });
//                     },
//                     child: const Text('Editar'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Implementar eliminación
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Eliminar'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         children: [
//           Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
//           Text(value),
//         ],
//       ),
//     );
//   }
}