// import 'package:flutter/material.dart';

// class InfiniteScrollList<T> extends StatefulWidget {
//   final List<T> items;
//   final bool isLoading;
//   final bool isLoadingMore;
//   final bool hasMore;
//   final String? error;
//   final Function() onLoadMore;
//   final Function()? onRefresh;
//   final Widget Function(BuildContext context, T item, int index) itemBuilder;
//   final Widget? loadingWidget;
//   final Widget? errorWidget;
//   final Widget? emptyWidget;
//   final Widget? footerLoadingWidget;
//   final ScrollController? scrollController;
//   final EdgeInsets? padding;
//   final Axis scrollDirection;

//   const InfiniteScrollList({
//     super.key,
//     required this.items,
//     required this.isLoading,
//     required this.isLoadingMore,
//     required this.hasMore,
//     required this.onLoadMore,
//     required this.itemBuilder,
//     this.onRefresh,
//     this.loadingWidget,
//     this.errorWidget,
//     this.emptyWidget,
//     this.footerLoadingWidget,
//     this.scrollController,
//     this.padding,
//     this.error,
//     this.scrollDirection = Axis.vertical,
//   });

//   @override
//   State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
// }

// class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = widget.scrollController ?? ScrollController();
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     if (widget.scrollController == null) {
//       _scrollController.dispose();
//     }
//     super.dispose();
//   }

//   void _scrollListener() {
//     if (!_scrollController.hasClients) return;
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !widget.isLoadingMore &&
//         !widget.isLoading &&
//         widget.hasMore) {
//       widget.onLoadMore();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.isLoading && widget.items.isEmpty) {
//       return widget.loadingWidget ??
//           const Center(child: CircularProgressIndicator());
//     }

//     if (widget.error != null) {
//       return widget.errorWidget ??
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Error: ${widget.error}'),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: widget.onLoadMore,
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//     }

//     if (widget.items.isEmpty) {
//       return widget.emptyWidget ??
//           const Center(child: Text('No hay datos.'));
//     }

//     final content = ListView.builder(
//       controller: _scrollController,
//       padding: widget.padding,
//       scrollDirection: widget.scrollDirection,
//       itemCount: widget.hasMore ? widget.items.length + 1 : widget.items.length,
//       itemBuilder: (context, index) {
//         if (index >= widget.items.length) {
//           return widget.footerLoadingWidget ??
//               const Center(child: CircularProgressIndicator());
//         }
//         return widget.itemBuilder(context, widget.items[index], index);
//       },
//     );

//     return widget.onRefresh != null
//         ? RefreshIndicator(
//             onRefresh: () async => widget.onRefresh!(),
//             child: content,
//           )
//         : content;
//   }
// }

// infinite_scroll_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfiniteScrollTable<T> extends ConsumerStatefulWidget {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final Function() onLoadMore;
  final Function(String) onSearch;
  final List<DataColumn> columns;
  final DataRow Function(T item) buildRow;
  final bool showEditDeleteButtons;
  final Function(T)? onEdit;
  final Function(T)? onDelete;
  final String searchHintText;
  final void Function(List<T>)? onMassDelete;
  final bool Function(T)? isItemSelected;
  final void Function(BuildContext, T)? onViewDetails;
  final Widget Function(BuildContext, WidgetRef, T)? detailViewBuilder;

  const InfiniteScrollTable({
    super.key,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    required this.onSearch,
    required this.columns,
    required this.buildRow,
    this.showEditDeleteButtons = false,
    this.onEdit,
    this.onDelete,
    this.error,
    this.searchHintText = 'Buscar',
    this.onMassDelete,
    this.isItemSelected,
    this.onViewDetails,
    this.detailViewBuilder,
  });

  @override
  ConsumerState<InfiniteScrollTable<T>> createState() => _InfiniteScrollTableState<T>();
}

class _InfiniteScrollTableState<T> extends ConsumerState<InfiniteScrollTable<T>> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isSelectionMode = false;
  final Set<T> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !widget.isLoadingMore &&
        !widget.isLoading &&
        widget.hasMore) {
      widget.onLoadMore();
    }
  }

  void toggleSelectionMode() {
    if (!widget.showEditDeleteButtons) return;
    setState(() {
      isSelectionMode = true;
    });
  }

  void cancelSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedItems.clear();
    });
  }

  void toggleItemSelection(T item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }

  void confirmMassDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Deseas eliminar ${selectedItems.length} elementos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed == true && widget.onMassDelete != null) {
      widget.onMassDelete!(selectedItems.toList());
      cancelSelectionMode();
    }
  }

  void _showDetails(BuildContext context, T item) {
    if (widget.detailViewBuilder != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => widget.detailViewBuilder!(context, ref, item),
      );
    } else if (widget.onViewDetails != null) {
      widget.onViewDetails!(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${widget.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onLoadMore,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (widget.items.isEmpty) {
      return const Center(child: Text('No se encontraron datos'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.searchHintText,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearch('');
                      },
                    ),
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.showEditDeleteButtons && !isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Borrado masivo',
                  onPressed: toggleSelectionMode,
                ),
              if (isSelectionMode) ...[
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eliminar seleccionados',
                  onPressed:
                      selectedItems.isNotEmpty ? confirmMassDelete : null,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancelar selección',
                  onPressed: cancelSelectionMode,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    if (isSelectionMode) const DataColumn(label: Text('')),
                    ...widget.columns,
                  ],
                  rows: widget.items.map((item) {
                    final row = widget.buildRow(item);
                    final cells = <DataCell>[];
                    
                    if (isSelectionMode) {
                      final isSelected = selectedItems.contains(item);
                      cells.add(
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => toggleItemSelection(item),
                          ),
                        ),
                      );
                    }
                    
                    for (int i = 0; i < row.cells.length; i++) {
                      final cell = row.cells[i];
                      cells.add(DataCell(
                        cell.child ?? const SizedBox(),
                        onTap: () => _showDetails(context, item),
                      ));
                    }
                    
                    return DataRow(cells: cells);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        if (widget.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}