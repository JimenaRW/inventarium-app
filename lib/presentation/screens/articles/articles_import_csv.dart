import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventarium/data/category_repository_provider.dart';
import 'package:inventarium/presentation/viewmodels/article/provider.dart';

class ArticlesImportCsv extends ConsumerStatefulWidget {
  static const String name = 'articles_import_csv';
  const ArticlesImportCsv({super.key});

  @override
  ConsumerState<ArticlesImportCsv> createState() => _ArticlesImportCsvState();
}

class _ArticlesImportCsvState extends ConsumerState<ArticlesImportCsv> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(articleImportCsvNotifierProvider);
      ref.read(articleImportCsvNotifierProvider.notifier).resetStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleImportCsvNotifierProvider);
    final notifier = ref.read(articleImportCsvNotifierProvider.notifier);

    Future<void> submitForm() async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        await ref
            .read(articleImportCsvNotifierProvider.notifier)
            .importArticles();

        ref.read(categoriesNotifierProvider.notifier);
        ref.read(articleSearchProvider.notifier).loadInitialData();

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Importación de ${state.importedCount} artículos realizada.',
            ),
          ),
        );
        navigator.pop(true);
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

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
                  onPressed: () async {
                    try {
                      await notifier.pickCsvFile();
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Seleccionar archivo CSV'),
                ),

                const SizedBox(height: 12),

                if (state.selectedFile != null)
                  Text(
                    'Archivo: ${state.selectedFile!.path.split(Platform.pathSeparator).last}: un total de ${state.importedCount ?? 0} artículos',
                  ),

                const SizedBox(height: 24),

                if (state.validationErrors.isNotEmpty &&
                    state.selectedFile != null) ...[
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
                ] else if (state.potentialArticles != null &&
                    state.selectedFile != null) ...[
                  const Text(
                    'Archivo válido ✅',
                    style: TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async => await submitForm(),
                    icon: const Icon(Icons.upload),
                    label: const Text('Importar artículos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                ],
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
