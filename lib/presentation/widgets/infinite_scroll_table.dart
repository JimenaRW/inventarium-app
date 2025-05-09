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
  });

  @override
  ConsumerState<InfiniteScrollTable<T>> createState() =>
      _InfiniteScrollTableState<T>();
}

class _InfiniteScrollTableState<T>
    extends ConsumerState<InfiniteScrollTable<T>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !widget.isLoadingMore &&
        !widget.isLoading &&
        widget.hasMore) {
      widget.onLoadMore();
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                // Lógica adicional si es necesaria
              }
              return false;
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: [
                    ...widget.columns,
                    if (widget.showEditDeleteButtons)
                      const DataColumn(label: Text('Acciones')),
                  ],
                  rows: [
                    ...widget.items.map((item) {
                      final row = widget.buildRow(item);
                      if (widget.showEditDeleteButtons) {
                        return DataRow(
                          cells: [
                            ...row.cells,
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => widget.onEdit?.call(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => widget.onDelete?.call(item),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return row;
                    }),
                    if (widget.isLoadingMore)
                      DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                          ...List<DataCell>.generate(
                            widget.columns.length +
                                (widget.showEditDeleteButtons ? 1 : 0) -
                                1,
                            (_) => const DataCell(SizedBox()),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
