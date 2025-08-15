import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../providers/database_providers.dart';

/// Servicio para gestionar categorías de productos
class CategoryService {
  final AppDatabase _database;
  static const Uuid _uuid = Uuid();

  CategoryService(this._database);

  /// Obtener todas las categorías activas
  Future<List<Category>> getAllCategories() async {
    return await _database.select(_database.categories).get();
  }

  /// Obtener categorías como stream para updates en tiempo real
  Stream<List<Category>> watchCategories() {
    return _database.select(_database.categories).watch();
  }

  /// Crear una nueva categoría
  Future<Category> createCategory(String name, {String? description}) async {
    final category = CategoriesCompanion.insert(
      uuid: _uuid.v4(),
      name: name.trim(),
      description: Value(description?.trim()),
    );

    final id = await _database.into(_database.categories).insert(category);
    return await (_database.select(_database.categories)
      ..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  /// Actualizar una categoría existente
  Future<void> updateCategory(
    String uuid,
    String name, {
    String? description,
  }) async {
    await (_database.update(_database.categories)
      ..where((tbl) => tbl.uuid.equals(uuid))).write(
      CategoriesCompanion(
        name: Value(name.trim()),
        description: Value(description?.trim()),
      ),
    );
  }

  /// Eliminar una categoría
  Future<void> deleteCategory(String uuid) async {
    await (_database.delete(_database.categories)
      ..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  /// Verificar si una categoría existe por nombre
  Future<bool> categoryExists(String name) async {
    final result =
        await (_database.select(_database.categories)
          ..where((tbl) => tbl.name.equals(name.trim()))).get();
    return result.isNotEmpty;
  }

  /// Obtener o crear una categoría por nombre
  Future<Category> getOrCreateCategory(String name) async {
    final trimmedName = name.trim();

    // Buscar categoría existente
    final existing =
        await (_database.select(_database.categories)
          ..where((tbl) => tbl.name.equals(trimmedName))).get();

    if (existing.isNotEmpty) {
      return existing.first;
    }

    // Crear nueva categoría si no existe
    return await createCategory(trimmedName);
  }

  /// Obtener nombres de categorías únicos para dropdown
  Future<List<String>> getCategoryNames() async {
    final categories = await getAllCategories();
    return categories.map((c) => c.name).toSet().toList()..sort();
  }

  /// Contar productos por categoría
  Future<Map<String, int>> getProductCountByCategory() async {
    final query = _database.customSelect(
      'SELECT category, COUNT(*) as count '
      'FROM products '
      'WHERE is_deleted = 0 AND category IS NOT NULL '
      'GROUP BY category',
      readsFrom: {_database.products},
    );

    final results = await query.get();
    final countMap = <String, int>{};

    for (final row in results) {
      final category = row.read<String>('category');
      final count = row.read<int>('count');
      countMap[category] = count;
    }

    return countMap;
  }
}

/// Provider para el servicio de categorías
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoryService(database);
});

/// Provider para obtener todas las categorías
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final service = ref.watch(categoryServiceProvider);
  return service.watchCategories();
});

/// Provider para obtener nombres de categorías para dropdown
final categoryNamesProvider = FutureProvider<List<String>>((ref) {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategoryNames();
});

/// Provider para contar productos por categoría
final categoryStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final service = ref.watch(categoryServiceProvider);
  return service.getProductCountByCategory();
});

/// Provider para crear una nueva categoría
final createCategoryProvider = FutureProvider.family<Category, String>((
  ref,
  name,
) {
  final service = ref.watch(categoryServiceProvider);
  return service.getOrCreateCategory(name);
});
