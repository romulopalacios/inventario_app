import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/reactive_providers.dart';
import '../../core/services/image_service.dart';

class ProductImageGallery extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final bool allowEdit;
  final Function(String imagePath)? onImageAdded;
  final Function(String imagePath)? onImageDeleted;

  const ProductImageGallery({
    super.key,
    required this.productId,
    required this.productName,
    this.allowEdit = true,
    this.onImageAdded,
    this.onImageDeleted,
  });

  @override
  ConsumerState<ProductImageGallery> createState() =>
      _ProductImageGalleryState();
}

class _ProductImageGalleryState extends ConsumerState<ProductImageGallery> {
  List<String> _imagePaths = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    try {
      final images = await ImageService.getProductImages(widget.productId);
      setState(() {
        _imagePaths = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar imágenes: $e')));
      }
    }
  }

  Future<void> _addImage() async {
    final imagePath = await ImageService.showImageSourceDialog(
      context,
      productId: widget.productId,
    );

    if (imagePath != null) {
      setState(() {
        _imagePaths.add(imagePath);
      });

      // Invalidar los providers para actualizar otras pantallas
      ref.read(imageInvalidationProvider.notifier).invalidateImages();

      widget.onImageAdded?.call(imagePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen agregada exitosamente')),
        );
      }
    }
  }

  Future<void> _deleteImage(String imagePath, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Imagen'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta imagen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await ImageService.deleteImage(imagePath);
      if (success) {
        setState(() {
          _imagePaths.removeAt(index);
        });

        // Invalidar los providers para actualizar otras pantallas
        ref.read(imageInvalidationProvider.notifier).invalidateImages();

        widget.onImageDeleted?.call(imagePath);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Imagen eliminada')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar imagen')),
          );
        }
      }
    }
  }

  void _viewImage(String imagePath, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => _ImageViewer(
              imagePaths: _imagePaths,
              initialIndex: initialIndex,
              productName: widget.productName,
              allowDelete: widget.allowEdit,
              onDelete: (index) {
                _deleteImage(_imagePaths[index], index);
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fotos del Producto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.allowEdit)
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: _addImage,
                    tooltip: 'Agregar Foto',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_imagePaths.isEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child:
                    widget.allowEdit
                        ? InkWell(
                          onTap: _addImage,
                          borderRadius: BorderRadius.circular(8),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Toca para agregar fotos',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                        : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No hay fotos disponibles',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length + (widget.allowEdit ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Botón "Agregar más" al final
                    if (widget.allowEdit && index == _imagePaths.length) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: InkWell(
                          onTap: _addImage,
                          borderRadius: BorderRadius.circular(8),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 32, color: Colors.grey),
                              Text(
                                'Agregar',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Imagen del producto
                    final imagePath = _imagePaths[index];
                    return Container(
                      width: 120,
                      margin: EdgeInsets.only(
                        right: index < _imagePaths.length - 1 ? 8 : 0,
                      ),
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: () => _viewImage(imagePath, index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(imagePath),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (widget.allowEdit)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed:
                                      () => _deleteImage(imagePath, index),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '${_imagePaths.length} foto${_imagePaths.length == 1 ? '' : 's'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final String productName;
  final bool allowDelete;
  final Function(int index)? onDelete;

  const _ImageViewer({
    required this.imagePaths,
    required this.initialIndex,
    required this.productName,
    this.allowDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        actions: [
          if (allowDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDelete?.call(initialIndex),
            ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.file(
                File(imagePaths[index]),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Error al cargar imagen'),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
