import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Products provider
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllProducts();
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllCategories();
});

// Inventory stats provider
final inventoryStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final db = ref.read(databaseProvider);
  return db.getInventoryStats();
});

// Low stock products provider
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getLowStockProducts();
});

// Product detail provider
final productDetailProvider = FutureProvider.family<Product?, String>((
  ref,
  uuid,
) async {
  final db = ref.read(databaseProvider);
  return db.getProductByUuid(uuid);
});

// Stock movements provider
final stockMovementsProvider =
    FutureProvider.family<List<StockMovement>, String>((
      ref,
      productUuid,
    ) async {
      final db = ref.read(databaseProvider);
      return db.getMovementsByProduct(productUuid);
    });

// Search products provider
class ProductSearchNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductSearchNotifier(this.ref) : super(const AsyncValue.data([]));

  final StateNotifierProviderRef<
    ProductSearchNotifier,
    AsyncValue<List<Product>>
  >
  ref;

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final db = ref.read(databaseProvider);
      final results = await db.searchProducts(query);
      state = AsyncValue.data(results);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

final productSearchProvider =
    StateNotifierProvider<ProductSearchNotifier, AsyncValue<List<Product>>>((
      ref,
    ) {
      return ProductSearchNotifier(ref);
    });

// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Filtered products based on category
final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final db = ref.read(databaseProvider);

  if (selectedCategory == null) {
    return db.getAllProducts();
  } else {
    return db.getProductsByCategory(selectedCategory);
  }
});
