import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArticlesShareCsv extends StatelessWidget {
  static const String name = 'articles_share_csv';
  const ArticlesShareCsv({super.key});

  @override
  Widget build(BuildContext context) {
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
            
            const Text(
              '1080 registros importados, comparta el archivo por email o whatsapp / drive',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}