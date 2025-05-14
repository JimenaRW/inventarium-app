import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

abstract class UPCRepository {
  Future<String> scanUPC(BuildContext context);
}

class UPCRepositoryImpl implements UPCRepository {
  @override
  Future<String> scanUPC(BuildContext context) async {
    final MobileScannerController controller = MobileScannerController(
      formats: [BarcodeFormat.all],
      facing: CameraFacing.back,
    );

    final result = await showDialog(
      context: context,
      builder:
          (context) => MobileScanner(
            controller: controller,
            onDetect: (barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              Navigator.of(context).pop(barcode.rawValue);
            },
          ),
    );

    return result;
  }
}
