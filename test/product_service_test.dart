import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_app/core/database/database.dart';
import 'package:inventario_app/core/services/inventory_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

void main() {
  group('Product Service Tests', () {
    late AppDatabase database;
    late ProductService productService;

    setUp(() async {
      // Use an in-memory database for testing
      database = AppDatabase();
      productService = ProductService(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should create a product', () async {
      await productService.createProduct(
        name: 'Test Product',
        code: 'TEST001',
        category: 'Test Category',
        purchasePrice: 10.0,
        salePrice: 15.0,
        stock: 100,
        minStock: 10,
        description: 'A test product',
      );

      final products = await database.getAllProducts();
      expect(products.length, 1);
      expect(products.first.name, 'Test Product');
      expect(products.first.code, 'TEST001');
      expect(products.first.salePrice, 15.0);
    });

    test('should add stock movement', () async {
      // First create a product
      await productService.createProduct(name: 'Test Product', stock: 50);

      final products = await database.getAllProducts();
      final productUuid = products.first.uuid;

      // Add an entrada movement
      await productService.addStockMovement(
        productUuid: productUuid,
        type: 'entrada',
        quantity: 25,
        reason: 'New stock',
      );

      // Check that stock was updated
      final updatedProduct = await database.getProductByUuid(productUuid);
      expect(updatedProduct!.stock, 75);

      // Check that movement was recorded
      final movements = await database.getMovementsByProduct(productUuid);
      expect(movements.length, 1);
      expect(movements.first.type, 'entrada');
      expect(movements.first.quantity, 25);
      expect(movements.first.previousStock, 50);
      expect(movements.first.newStock, 75);
    });

    test('should calculate inventory stats', () async {
      // Create multiple products
      await productService.createProduct(
        name: 'Product 1',
        salePrice: 10.0,
        stock: 5,
        minStock: 10, // Low stock
      );

      await productService.createProduct(
        name: 'Product 2',
        salePrice: 20.0,
        stock: 15,
        minStock: 5,
      );

      final stats = await database.getInventoryStats();

      expect(stats['totalProducts'], 2);
      expect(stats['totalValue'], 350.0); // (10*5) + (20*15)
      expect(stats['lowStockCount'], 1); // Only Product 1 has low stock
    });
  });
}
