import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';

class ArticlesImportCsv extends ConsumerWidget {
  static const String name = 'articles_import_csv';
  const ArticlesImportCsv({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articleImportCsvNotifierProvider);
    final notifier = ref.read(articleImportCsvNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar CSV'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Importador de artículos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () => notifier.pickCsvFile(),
                  child: const Text('Seleccionar archivo CSV'),
                ),

                const SizedBox(height: 12),

                if (state.selectedFile != null)
                  Text(
                    'Archivo: ${state.selectedFile!.path.split(Platform.pathSeparator).last}',
                  ),

                const SizedBox(height: 24),

                if (state.validationErrors.isNotEmpty) ...[
                  const Text(
                    'Errores de validación:',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.validationErrors.length,
                      itemBuilder:
                          (ctx, index) => Text(
                            '• ${state.validationErrors[index]}',
                            style: const TextStyle(color: Colors.red),
                          ),
                    ),
                  ),
                ] else if (state.potentialArticles != null) ...[
                  const Text(
                    'Archivo válido ✅',
                    style: TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => notifier.importArticles(),
                    icon: const Icon(Icons.upload),
                    label: const Text('Importar artículos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                ],

                if (state.importSuccess)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      'Importación completada exitosamente ✅',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            if (state.isLoading)
              Container(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
