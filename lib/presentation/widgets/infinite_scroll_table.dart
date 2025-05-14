import 'package:data_table_2/data_table_2.dart';
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
  });

  @override
  ConsumerState<InfiniteScrollTable<T>> createState() =>
      _InfiniteScrollTableState<T>();
}

class _InfiniteScrollTableState<T>
    extends ConsumerState<InfiniteScrollTable<T>> {
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
      builder:
          (context) => AlertDialog(
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
        Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                headingRowHeight: 48,
                dataRowHeight: 56,
                columns: [
                  if (isSelectionMode) const DataColumn2(label: Text('')),
                  ...widget.columns,
                ],
                rows:
                    widget.items.map((item) {
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
                        final isDescripcionColumn =
                            widget.columns[i].label is Text &&
                            (widget.columns[i].label as Text).data
                                    ?.toLowerCase() ==
                                'descripción';

                        cells.add(
                          isDescripcionColumn && widget.onViewDetails != null
                              ? DataCell(
                                cell.child!,
                                onTap:
                                    () => widget.onViewDetails!(context, item),
                              )
                              : cell,
                        );
                      }
                      return DataRow(cells: cells);
                    }).toList(),
              ),
            ),
          ),
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
