import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/core/menu/drawer_menu.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';
import 'package:inventarium/presentation/widgets/infinite_scroll_table.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String name = 'home_screen';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleSearchProvider.notifier).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleSearchProvider);
    final notifier = ref.read(articleSearchProvider.notifier);

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: const Text("Inicio"),
      ),
      drawer: DrawerMenu(scafoldKey:  widget.scaffoldKey),
      // body: InfiniteScrollTable<Article>(
      //   items: state.articles,
      //   isLoading: state.isLoading,
      //   isLoadingMore: state.isLoadingMore,
      //   hasMore: state.hasMore,
      //   onLoadMore: notifier.loadMoreArticles,
      //   onSearch: notifier.searchArticles,
      //   searchHintText: 'Buscar artículos...',
      //   showEditDeleteButtons: false, // O ajusta según necesidades
      //   columns: const [
      //     DataColumn(label: Text('SKU')),
      //     DataColumn(label: Text('Descripción')),
      //     DataColumn(label: Text('Stock'), numeric: true),
      //     DataColumn(label: Text('Precio1'), numeric: true),
      //   ],
      //   buildRow: (article) => DataRow(
      //     cells: [
      //       DataCell(Text(article.sku)),
      //       DataCell(Text(article.descripcion)),
      //       DataCell(Text(article.stock.toString())),
      //       DataCell(Text(article.precio1.toString())),
      //     ],
      //   ),
      // ),
    
    );
  }
}
