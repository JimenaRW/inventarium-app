import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';

class ArticlesShareCsv extends ConsumerWidget {
  static const String name = 'articles_share_csv';
  const ArticlesShareCsv({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportedCount = ref.watch(
      articleExportsCsvNotifierProvider.select((state) => state.exportedCount),
    );
    final lastExportedUrl = ref.watch(
      articleExportsCsvNotifierProvider.select((state) => state.lastExportedCsvUrl),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar CSV'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ARTÍCULO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'EXPORTACIÓN EXITOSA!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$exportedCount registros exportados',
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton(
                onPressed: lastExportedUrl != null 
                    ? () => _shareFile(context, lastExportedUrl)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'COMPARTIR ARCHIVO',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  void _shareFile(BuildContext context, String fileUrl) {
    // Implementa la lógica de compartir usando plugins como `share_plus`
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compartir archivo'),
        content: Text('¿Compartir reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Ejemplo con share_plus:
              // Share.share('Descarga el CSV: $fileUrl');
              Navigator.pop(ctx);
            },
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
  }
}