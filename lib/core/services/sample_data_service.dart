import 'inventory_service.dart';
import '../database/database.dart';

/// Sample data to help users get started with the app
class SampleDataService {
  final ProductService _productService;

  SampleDataService(this._productService);

  /// Creates sample products to demonstrate the app
  Future<void> createSampleData() async {
    final sampleProducts = [
      {
        'name': 'Martillo',
        'code': 'MART001',
        'category': 'Herramientas',
        'purchasePrice': 15.0,
        'salePrice': 25.0,
        'stock': 10,
        'minStock': 5,
        'description': 'Martillo de carpintero de 16 oz',
      },
      {
        'name': 'Destornillador Phillips',
        'code': 'DEST002',
        'category': 'Herramientas',
        'purchasePrice': 3.0,
        'salePrice': 8.0,
        'stock': 25,
        'minStock': 10,
        'description': 'Destornillador Phillips mediano',
      },
      {
        'name': 'Cuaderno A4',
        'code': 'CUAD003',
        'category': 'Papelería',
        'purchasePrice': 2.0,
        'salePrice': 5.0,
        'stock': 50,
        'minStock': 20,
        'description': 'Cuaderno universitario de 100 hojas',
      },
      {
        'name': 'Bolígrafo Azul',
        'code': 'BOLI004',
        'category': 'Papelería',
        'purchasePrice': 0.5,
        'salePrice': 1.5,
        'stock': 100,
        'minStock': 30,
        'description': 'Bolígrafo de tinta azul',
      },
      {
        'name': 'Tornillos 1/4"',
        'code': 'TORN005',
        'category': 'Ferretería',
        'purchasePrice': 0.1,
        'salePrice': 0.25,
        'stock': 2,
        'minStock': 50,
        'description': 'Tornillos de acero inoxidable 1/4 pulgada',
      },
      {
        'name': 'Pintura Blanca',
        'code': 'PINT006',
        'category': 'Pintura',
        'purchasePrice': 12.0,
        'salePrice': 20.0,
        'stock': 15,
        'minStock': 5,
        'description': 'Pintura látex blanca 1 galón',
      },
      {
        'name': 'Brocha 2"',
        'code': 'BROC007',
        'category': 'Pintura',
        'purchasePrice': 4.0,
        'salePrice': 8.0,
        'stock': 12,
        'minStock': 8,
        'description': 'Brocha para pintura de 2 pulgadas',
      },
      {
        'name': 'Lápiz #2',
        'code': 'LAPI008',
        'category': 'Papelería',
        'purchasePrice': 0.3,
        'salePrice': 0.8,
        'stock': 3,
        'minStock': 20,
        'description': 'Lápiz de grafito número 2',
      },
    ];

    for (final productData in sampleProducts) {
      await _productService.createProduct(
        name: productData['name'] as String,
        code: productData['code'] as String,
        category: productData['category'] as String,
        purchasePrice: productData['purchasePrice'] as double,
        salePrice: productData['salePrice'] as double,
        stock: productData['stock'] as int,
        minStock: productData['minStock'] as int,
        description: productData['description'] as String,
      );
    }

    // Add some sample stock movements
    final db = AppDatabase();
    final products = await db.getAllProducts();

    if (products.isNotEmpty) {
      // Add a sale movement for the first product
      await _productService.addStockMovement(
        productUuid: products[0].uuid,
        type: 'salida',
        quantity: 2,
        reason: 'Venta',
        notes: 'Vendido a cliente local',
      );

      // Add a purchase movement for the second product
      if (products.length > 1) {
        await _productService.addStockMovement(
          productUuid: products[1].uuid,
          type: 'entrada',
          quantity: 10,
          reason: 'Compra',
          notes: 'Nueva mercancía del proveedor',
        );
      }

      // Add an adjustment for the third product
      if (products.length > 2) {
        await _productService.addStockMovement(
          productUuid: products[2].uuid,
          type: 'ajuste',
          quantity: 45,
          reason: 'Inventario físico',
          notes: 'Ajuste por conteo físico',
        );
      }
    }

    await db.close();
  }

  /// Creates sample categories
  Future<void> createSampleCategories() async {
    final db = AppDatabase();
    final categoryService = CategoryService(db);

    final categories = [
      {
        'name': 'Herramientas',
        'description': 'Herramientas de mano y eléctricas',
      },
      {'name': 'Papelería', 'description': 'Artículos de oficina y escolares'},
      {'name': 'Ferretería', 'description': 'Tornillos, tuercas y accesorios'},
      {'name': 'Pintura', 'description': 'Pinturas y accesorios para pintar'},
      {
        'name': 'Electricidad',
        'description': 'Componentes y accesorios eléctricos',
      },
    ];

    for (final categoryData in categories) {
      await categoryService.createCategory(
        name: categoryData['name']!,
        description: categoryData['description'],
      );
    }

    await db.close();
  }
}
