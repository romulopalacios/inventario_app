import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../providers/database_providers.dart';

const _uuid = Uuid();

class ProductService {
  final AppDatabase _database;

  ProductService(this._database);

  Future<void> createProduct({
    required String name,
    String? code,
    String? category,
    double purchasePrice = 0,
    double salePrice = 0,
    int stock = 0,
    int minStock = 0,
    String? description,
    String? imagePath,
  }) async {
    final product = ProductsCompanion(
      uuid: Value(_uuid.v4()),
      name: Value(name),
      code: Value(code),
      category: Value(category),
      purchasePrice: Value(purchasePrice),
      salePrice: Value(salePrice),
      stock: Value(stock),
      minStock: Value(minStock),
      description: Value(description),
      imagePath: Value(imagePath),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await _database.insertProduct(product);
  }

  Future<void> updateProduct({
    required String uuid,
    required String name,
    String? code,
    String? category,
    double purchasePrice = 0,
    double salePrice = 0,
    int stock = 0,
    int minStock = 0,
    String? description,
    String? imagePath,
  }) async {
    final existingProduct = await _database.getProductByUuid(uuid);
    if (existingProduct == null) {
      throw Exception('Product not found');
    }

    final updatedProduct = existingProduct.copyWith(
      name: name,
      code: Value(code),
      category: Value(category),
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      stock: stock,
      minStock: minStock,
      description: Value(description),
      imagePath: Value(imagePath),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _database.updateProduct(updatedProduct);
  }

  Future<void> deleteProduct(String uuid) async {
    await _database.deleteProduct(uuid);
  }

  Future<void> addStockMovement({
    required String productUuid,
    required String type, // 'entrada', 'salida', 'ajuste'
    required int quantity,
    double? unitPrice,
    String? reason,
    String? notes,
  }) async {
    final product = await _database.getProductByUuid(productUuid);
    if (product == null) {
      throw Exception('Product not found');
    }

    final previousStock = product.stock;
    int newStock;

    switch (type) {
      case 'entrada':
        newStock = previousStock + quantity;
        break;
      case 'salida':
        newStock = previousStock - quantity;
        if (newStock < 0) newStock = 0;
        break;
      case 'ajuste':
        newStock = quantity;
        break;
      default:
        throw Exception('Invalid movement type');
    }

    // Create stock movement record
    final movement = StockMovementsCompanion(
      uuid: Value(_uuid.v4()),
      productUuid: Value(productUuid),
      type: Value(type),
      quantity: Value(quantity),
      previousStock: Value(previousStock),
      newStock: Value(newStock),
      unitPrice: Value(unitPrice),
      reason: Value(reason),
      notes: Value(notes),
      createdAt: Value(DateTime.now()),
    );

    await _database.insertStockMovement(movement);

    // Update product stock
    final updatedProduct = product.copyWith(
      stock: newStock,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _database.updateProduct(updatedProduct);
  }
}

class CategoryService {
  final AppDatabase _database;

  CategoryService(this._database);

  Future<void> createCategory({
    required String name,
    String? description,
  }) async {
    final category = CategoriesCompanion(
      uuid: Value(_uuid.v4()),
      name: Value(name),
      description: Value(description),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await _database.insertCategory(category);
  }

  Future<List<String>> getCategoryNames() async {
    final categories = await _database.getAllCategories();
    return categories.map((c) => c.name).toList();
  }
}

// Providers for services
final productServiceProvider = Provider<ProductService>((ref) {
  final database = ref.read(databaseProvider);
  return ProductService(database);
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final database = ref.read(databaseProvider);
  return CategoryService(database);
});

// Action providers for UI operations
final createProductProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final service = ref.read(productServiceProvider);
    await service.createProduct(
      name: params['name'],
      code: params['code'],
      category: params['category'],
      purchasePrice: params['purchasePrice'] ?? 0.0,
      salePrice: params['salePrice'] ?? 0.0,
      stock: params['stock'] ?? 0,
      minStock: params['minStock'] ?? 0,
      description: params['description'],
      imagePath: params['imagePath'],
    );

    // Refresh products list
    ref.invalidate(productsProvider);
    ref.invalidate(inventoryStatsProvider);
  },
);

final updateProductProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final service = ref.read(productServiceProvider);
    await service.updateProduct(
      uuid: params['uuid'],
      name: params['name'],
      code: params['code'],
      category: params['category'],
      purchasePrice: params['purchasePrice'] ?? 0.0,
      salePrice: params['salePrice'] ?? 0.0,
      stock: params['stock'] ?? 0,
      minStock: params['minStock'] ?? 0,
      description: params['description'],
      imagePath: params['imagePath'],
    );

    // Refresh relevant providers
    ref.invalidate(productsProvider);
    ref.invalidate(productDetailProvider(params['uuid']));
    ref.invalidate(inventoryStatsProvider);
  },
);

final addStockMovementProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
      final service = ref.read(productServiceProvider);
      await service.addStockMovement(
        productUuid: params['productUuid'],
        type: params['type'],
        quantity: params['quantity'],
        unitPrice: params['unitPrice'],
        reason: params['reason'],
        notes: params['notes'],
      );

      // Refresh relevant providers
      ref.invalidate(productsProvider);
      ref.invalidate(productDetailProvider(params['productUuid']));
      ref.invalidate(stockMovementsProvider(params['productUuid']));
      ref.invalidate(inventoryStatsProvider);
    });

final deleteProductProvider = FutureProvider.family<void, String>((
  ref,
  uuid,
) async {
  final service = ref.read(productServiceProvider);
  await service.deleteProduct(uuid);

  // Refresh products list
  ref.invalidate(productsProvider);
  ref.invalidate(inventoryStatsProvider);
});
