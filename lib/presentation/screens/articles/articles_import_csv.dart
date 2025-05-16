import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';

class ArticlesImportCsv extends ConsumerWidget {
  static const String name = 'articles_import_csv';
  const ArticlesImportCsv({super.key});

  Future<double> _getFileSizeInKB(File file) async {
    final bytes = await file.length();
    return bytes / 1024;
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ARTÍCULO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'SELECCIONE ARCHIVO CSV',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => notifier.pickCsvFile(),
              child: const Text('Seleccionar desde dispositivo'),
            ),
            const SizedBox(height: 8),

            if (state.selectedFile != null) ...[
              const SizedBox(height: 16),
              Text('Archivo seleccionado: ${state.selectedFile!.path}'),
              const SizedBox(height: 8),
              FutureBuilder<double>(
                future: _getFileSizeInKB(state.selectedFile!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error al leer tamaño del archivo');
                  } else {
                    return Text('Tamaño: ${snapshot.data!.toStringAsFixed(2)} KB');
                  }
                },
              ),
            ],

            const SizedBox(height: 32),

            if (state.validationErrors.isNotEmpty) ...[
              const Text(
                'ERRORES DE VALIDACIÓN:',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: state.validationErrors.length,
                  itemBuilder: (ctx, index) => Text(
                    '• ${state.validationErrors[index]}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],

            if (state.validationErrors.isEmpty &&
                state.selectedFile != null &&
                state.rawArticleLines != null) ...[
              const SizedBox(height: 16),
              const Text(
                'ARCHIVO VÁLIDO',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => notifier.importArticles(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'IMPORTAR CSV',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
