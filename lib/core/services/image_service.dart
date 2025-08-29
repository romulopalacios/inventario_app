import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static const int maxImageSize = 1024; // Max width/height
  static const int jpegQuality = 85; // Calidad JPEG (0-100)

  /// Seleccionar imagen desde cámara o galería
  static Future<String?> pickImage({
    required ImageSource source,
    String? productId,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: jpegQuality,
        maxWidth: maxImageSize.toDouble(),
        maxHeight: maxImageSize.toDouble(),
      );

      if (image == null) return null;

      // Crear directorio para imágenes si no existe
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'product_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generar nombre único para la imagen
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(image.path);
      final fileName =
          productId != null
              ? '${productId}_$timestamp$extension'
              : 'product_$timestamp$extension';

      final finalPath = path.join(imagesDir.path, fileName);

      // Copiar imagen al directorio de la app
      final File imageFile = File(image.path);
      await imageFile.copy(finalPath);

      return finalPath;
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      return null;
    }
  }

  /// Mostrar opciones de selección de imagen
  static Future<String?> showImageSourceDialog(
    BuildContext context, {
    String? productId,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickImage(
                    source: ImageSource.camera,
                    productId: productId,
                  );
                  Navigator.pop(context, imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de Galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickImage(
                    source: ImageSource.gallery,
                    productId: productId,
                  );
                  Navigator.pop(context, imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Eliminar imagen del almacenamiento local
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al eliminar imagen: $e');
      return false;
    }
  }

  /// Obtener todas las imágenes de un producto
  static Future<List<String>> getProductImages(String productId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'product_images'));

      if (!await imagesDir.exists()) return [];

      final files =
          imagesDir
              .listSync()
              .where((file) => file.path.contains(productId))
              .map((file) => file.path)
              .toList();

      return files;
    } catch (e) {
      debugPrint('Error al obtener imágenes del producto: $e');
      return [];
    }
  }

  /// Limpiar imágenes huérfanas (sin producto asociado)
  static Future<void> cleanupOrphanImages(List<String> validProductIds) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'product_images'));

      if (!await imagesDir.exists()) return;

      final files = imagesDir.listSync();

      for (final file in files) {
        final fileName = path.basename(file.path);
        final productId = fileName.split('_').first;

        // Si el ID del producto no existe, eliminar la imagen
        if (!validProductIds.contains(productId)) {
          await file.delete();
          debugPrint('Imagen huérfana eliminada: $fileName');
        }
      }
    } catch (e) {
      debugPrint('Error al limpiar imágenes huérfanas: $e');
    }
  }

  /// Obtener el tamaño total de imágenes almacenadas
  static Future<int> getTotalImagesSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'product_images'));

      if (!await imagesDir.exists()) return 0;

      int totalSize = 0;
      final files = imagesDir.listSync();

      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error al calcular tamaño de imágenes: $e');
      return 0;
    }
  }

  /// Formatear tamaño de archivo legible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
