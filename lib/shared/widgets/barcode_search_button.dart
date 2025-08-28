import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/barcode_scanner_service.dart';

class BarcodeSearchButton extends ConsumerWidget {
  final Function(String code) onCodeScanned;
  final String? tooltip;

  const BarcodeSearchButton({
    super.key,
    required this.onCodeScanned,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner),
      tooltip: tooltip ?? 'Buscar por código de barras',
      onPressed: () => _scanAndSearch(context),
    );
  }

  Future<void> _scanAndSearch(BuildContext context) async {
    try {
      // Verificar si la cámara está disponible
      final isCameraAvailable = await BarcodeScannerService.isCameraAvailable();

      if (!isCameraAvailable) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cámara no disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Escanear código
      final scannedCode = await BarcodeScannerService.scanBarcode(context);

      if (scannedCode != null && scannedCode.isNotEmpty) {
        // Llamar al callback con el código escaneado
        onCodeScanned(scannedCode);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Buscando: $scannedCode'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
