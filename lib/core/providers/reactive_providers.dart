import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../services/image_service.dart';

// Provider para imágenes de productos con invalidación automática
final productImagesProvider = FutureProvider.family<List<String>, String>((
  ref,
  productId,
) async {
  // Escuchar el invalidador de imágenes
  ref.watch(imageInvalidationProvider);

  return ImageService.getProductImages(productId);
});

// Provider para productos que se puede invalidar
final reactiveProductsProvider = FutureProvider<List<Product>>((ref) async {
  // Escuchar el invalidador de productos
  ref.watch(productInvalidationProvider);

  final db = ref.read(databaseProvider);
  return db.getAllProducts();
});

// Provider para categorías que se puede invalidar
final reactiveCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  // Escuchar el invalidador de categorías
  ref.watch(categoryInvalidationProvider);

  final db = ref.read(databaseProvider);
  return db.getAllCategories();
});

// Provider para producto individual que se puede invalidar
final reactiveProductProvider = FutureProvider.family<Product?, String>((
  ref,
  productId,
) async {
  // Escuchar el invalidador de productos
  ref.watch(productInvalidationProvider);

  final db = ref.read(databaseProvider);
  return db.getProductByUuid(productId);
});

// Provider para la imagen principal de un producto
final productMainImageProvider = FutureProvider.family<File?, String>((
  ref,
  productId,
) async {
  final images = await ref.watch(productImagesProvider(productId).future);
  if (images.isNotEmpty) {
    return File(images.first);
  }
  return null;
});

// Notificadores para invalidación
class ImageInvalidationNotifier extends StateNotifier<int> {
  ImageInvalidationNotifier() : super(0);

  void invalidateImages([String? productId]) {
    state++;
  }
}

class ProductInvalidationNotifier extends StateNotifier<int> {
  ProductInvalidationNotifier() : super(0);

  void invalidateProducts() {
    state++;
  }
}

class CategoryInvalidationNotifier extends StateNotifier<int> {
  CategoryInvalidationNotifier() : super(0);

  void invalidateCategories() {
    state++;
  }
}

// Providers de invalidadores
final imageInvalidationProvider =
    StateNotifierProvider<ImageInvalidationNotifier, int>((ref) {
      return ImageInvalidationNotifier();
    });

final productInvalidationProvider =
    StateNotifierProvider<ProductInvalidationNotifier, int>((ref) {
      return ProductInvalidationNotifier();
    });

final categoryInvalidationProvider =
    StateNotifierProvider<CategoryInvalidationNotifier, int>((ref) {
      return CategoryInvalidationNotifier();
    });

// Database provider (mantenido para compatibilidad)
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
