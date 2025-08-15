import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Importar todas las tablas
part 'database.g.dart';

// Tabla de productos
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get code => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();
  RealColumn get salePrice => real().withDefault(const Constant(0))();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get minStock => integer().withDefault(const Constant(0))();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// Tabla de movimientos de stock
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get productUuid => text().references(Products, #uuid)();
  TextColumn get type => text()(); // 'entrada', 'salida', 'ajuste'
  IntColumn get quantity => integer()();
  IntColumn get previousStock => integer()();
  IntColumn get newStock => integer()();
  RealColumn get unitPrice => real().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// Tabla de categorías
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// Tabla de configuración de usuario
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Products, StockMovements, Categories, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );

  // Products queries
  Future<List<Product>> getAllProducts() {
    return (select(products)
      ..where((tbl) => tbl.isDeleted.equals(false))).get();
  }

  Future<Product?> getProductByUuid(String uuid) {
    return (select(products)
      ..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<List<Product>> getProductsByCategory(String category) {
    return (select(products)..where(
      (tbl) => tbl.category.equals(category) & tbl.isDeleted.equals(false),
    )).get();
  }

  Future<List<Product>> searchProducts(String query) {
    return (select(products)..where(
      (tbl) =>
          (tbl.name.contains(query) | tbl.code.contains(query)) &
          tbl.isDeleted.equals(false),
    )).get();
  }

  Future<List<Product>> getLowStockProducts() {
    return (select(products)
      ..where((tbl) => tbl.isDeleted.equals(false))).get().then((allProducts) {
      return allProducts
          .where((product) => product.stock <= product.minStock)
          .toList();
    });
  }

  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }

  Future<int> deleteProduct(String uuid) {
    return (update(products)..where(
      (tbl) => tbl.uuid.equals(uuid),
    )).write(const ProductsCompanion(isDeleted: Value(true)));
  }

  // Stock movements queries
  Future<List<StockMovement>> getMovementsByProduct(String productUuid) {
    return (select(stockMovements)
          ..where((tbl) => tbl.productUuid.equals(productUuid))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  Future<int> insertStockMovement(StockMovementsCompanion movement) {
    return into(stockMovements).insert(movement);
  }

  // Categories queries
  Future<List<Category>> getAllCategories() {
    return (select(categories)
      ..where((tbl) => tbl.isDeleted.equals(false))).get();
  }

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  // Settings queries
  Future<String?> getSetting(String key) async {
    final setting =
        await (select(userSettings)
          ..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion(
        key: Value(key),
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Inventory calculations
  Future<Map<String, dynamic>> getInventoryStats() async {
    final allProducts = await getAllProducts();
    final totalProducts = allProducts.length;
    final totalValue = allProducts.fold<double>(
      0,
      (sum, product) => sum + (product.salePrice * product.stock),
    );
    final lowStockCount =
        allProducts
            .where((product) => product.stock <= product.minStock)
            .length;

    return {
      'totalProducts': totalProducts,
      'totalValue': totalValue,
      'lowStockCount': lowStockCount,
    };
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'inventario_db');
}
