import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/presentation/viewmodels/article/notifiers/upc_notifier.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  static const String name = 'barcode-scanner';

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  @override
  Widget build(BuildContext context) {
    final upcState = ref.watch(upcNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Lector de código de barras')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (upcState.isLoading)
              CircularProgressIndicator()
            else if (upcState.scanResult.isNotEmpty)
              Text('Código de barras: ${upcState.scanResult}')
            else if (upcState.error != null)
              Text('Error: ${upcState.error}')
            else
              Text('Presiona el botón para escanear'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(upcNotifierProvider.notifier).scanUPC(context);
              },
              child: Text('Escanear código de barras'),
            ),
          ],
        ),
      ),
    );
  }
}
