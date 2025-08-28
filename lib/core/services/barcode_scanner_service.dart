import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerService {
  /// Escanear código de barras y devolver el resultado
  static Future<String?> scanBarcode(BuildContext context) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const _BarcodeScannerScreen()),
    );
  }

  /// Verificar si el dispositivo tiene cámara disponible
  static Future<bool> isCameraAvailable() async {
    try {
      // Intentar crear un controller para verificar disponibilidad
      final controller = MobileScannerController();
      await controller.start();
      await controller.stop();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validar formato de código de barras
  static bool isValidBarcode(String code) {
    // Eliminar espacios y caracteres especiales
    final cleanCode = code.replaceAll(RegExp(r'[^0-9]'), '');

    // Verificar longitudes comunes de códigos de barras
    final validLengths = [8, 12, 13, 14]; // UPC-A, UPC-E, EAN-13, EAN-14, etc.

    return cleanCode.isNotEmpty &&
        validLengths.contains(cleanCode.length) &&
        cleanCode.length >= 4; // Mínimo 4 dígitos
  }

  /// Formatear código de barras para mostrar
  static String formatBarcode(String code) {
    final cleanCode = code.replaceAll(RegExp(r'[^0-9]'), '');

    // Formatear según la longitud
    switch (cleanCode.length) {
      case 8: // UPC-E
        return '${cleanCode.substring(0, 1)}-${cleanCode.substring(1, 7)}-${cleanCode.substring(7)}';
      case 12: // UPC-A
        return '${cleanCode.substring(0, 1)}-${cleanCode.substring(1, 6)}-${cleanCode.substring(6, 11)}-${cleanCode.substring(11)}';
      case 13: // EAN-13
        return '${cleanCode.substring(0, 1)}-${cleanCode.substring(1, 7)}-${cleanCode.substring(7, 12)}-${cleanCode.substring(12)}';
      default:
        return cleanCode;
    }
  }

  /// Obtener información del tipo de código
  static String getBarcodeTypeName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'Código QR';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.upcE:
        return 'UPC-E';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.aztec:
        return 'Aztec';
      case BarcodeFormat.codabar:
        return 'Codabar';
      case BarcodeFormat.itf:
        return 'ITF';
      default:
        return 'Desconocido';
    }
  }
}

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  late MobileScannerController _controller;
  bool _isScanning = true;
  String? _scannedCode;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        setState(() {
          _isScanning = false;
          _scannedCode = code;
        });

        // Vibrar al escanear (si está disponible)
        // HapticFeedback.vibrate();

        _showResultDialog(code, barcode.format);
      }
    }
  }

  void _showResultDialog(String code, BarcodeFormat format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Código Escaneado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo: ${BarcodeScannerService.getBarcodeTypeName(format)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Código: $code'),
                const SizedBox(height: 8),
                if (BarcodeScannerService.isValidBarcode(code))
                  Text(
                    'Formato: ${BarcodeScannerService.formatBarcode(code)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetScanning();
                },
                child: const Text('Escanear Otro'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, code);
                },
                child: const Text('Usar Este Código'),
              ),
            ],
          ),
    );
  }

  void _resetScanning() {
    setState(() {
      _isScanning = true;
      _scannedCode = null;
    });
  }

  void _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off),
            onPressed: _toggleTorch,
            tooltip: 'Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Cámara del scanner
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay con marco de escaneo
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Stack(
              children: [
                // Área transparente en el centro
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isScanning ? Colors.green : Colors.orange,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Instrucciones
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isScanning
                              ? Icons.qr_code_scanner
                              : Icons.check_circle,
                          color: _isScanning ? Colors.white : Colors.green,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isScanning
                              ? 'Apunta la cámara al código de barras'
                              : 'Código detectado: $_scannedCode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
