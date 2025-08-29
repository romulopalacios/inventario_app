import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../services/image_service.dart';
import '../services/financial_service.dart';

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

// Provider para el servicio financiero
final financialServiceProvider = Provider<FinancialService>((ref) {
  final database = ref.read(databaseProvider);
  return FinancialService(database);
});

// Provider para datos financieros con invalidación automática
final financialDataProvider =
    FutureProvider.family<FinancialData, Map<String, DateTime?>>((
      ref,
      params,
    ) async {
      // Escuchar invalidadores
      ref.watch(financialInvalidationProvider);
      ref.watch(productInvalidationProvider);

      final financialService = ref.read(financialServiceProvider);
      return financialService.getFinancialData(
        desde: params['desde'],
        hasta: params['hasta'],
      );
    });

// Provider para resumen financiero
final financialSummaryProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  ref.watch(financialInvalidationProvider);
  ref.watch(productInvalidationProvider);

  final financialService = ref.read(financialServiceProvider);
  return financialService.getFinancialSummary();
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

class FinancialInvalidationNotifier extends StateNotifier<int> {
  FinancialInvalidationNotifier() : super(0);

  void invalidateFinancials() {
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

final financialInvalidationProvider =
    StateNotifierProvider<FinancialInvalidationNotifier, int>((ref) {
      return FinancialInvalidationNotifier();
    });

// Provider para ventas diarias
final dailySalesProvider =
    FutureProvider.family<List<VentasDiarias>, Map<String, DateTime?>>((
      ref,
      params,
    ) async {
      ref.watch(financialInvalidationProvider);
      ref.watch(productInvalidationProvider);

      final financialService = ref.read(financialServiceProvider);
      final financialData = await financialService.getFinancialData(
        desde: params['desde'],
        hasta: params['hasta'],
      );
      return financialData.ventasDiarias;
    });

// Provider para productos más vendidos
final topProductsProvider =
    FutureProvider.family<List<ProductoMasVendido>, Map<String, DateTime?>>((
      ref,
      params,
    ) async {
      ref.watch(financialInvalidationProvider);
      ref.watch(productInvalidationProvider);

      final financialService = ref.read(financialServiceProvider);
      final financialData = await financialService.getFinancialData(
        desde: params['desde'],
        hasta: params['hasta'],
      );
      return financialData.productosMasVendidos;
    });

// Provider para ventas por categoría
final categorySalesProvider =
    FutureProvider.family<Map<String, double>, Map<String, DateTime?>>((
      ref,
      params,
    ) async {
      ref.watch(financialInvalidationProvider);
      ref.watch(productInvalidationProvider);

      final financialService = ref.read(financialServiceProvider);
      final financialData = await financialService.getFinancialData(
        desde: params['desde'],
        hasta: params['hasta'],
      );
      return financialData.ventasPorCategoria;
    });

// Database provider (mantenido para compatibilidad)
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
