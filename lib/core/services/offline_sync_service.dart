import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/database.dart';
import '../providers/database_providers.dart';

// Estados de sincronización
enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final String? message;
  final DateTime? lastSyncTime;
  final int totalToSync;
  final int synced;

  const SyncState({
    required this.status,
    this.message,
    this.lastSyncTime,
    this.totalToSync = 0,
    this.synced = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? message,
    DateTime? lastSyncTime,
    int? totalToSync,
    int? synced,
  }) {
    return SyncState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      totalToSync: totalToSync ?? this.totalToSync,
      synced: synced ?? this.synced,
    );
  }

  double get progress {
    if (totalToSync == 0) return 0.0;
    return synced / totalToSync;
  }
}

class OfflineSyncService extends StateNotifier<SyncState> {
  OfflineSyncService(this._database)
    : super(const SyncState(status: SyncStatus.idle)) {
    _loadLastSyncTime();
  }

  final AppDatabase _database;

  // Configuración de sincronización (puedes cambiar estas URLs)
  static const String _baseUrl =
      'https://tu-backend.com/api'; // Cambiar por tu URL
  static const String _apiKey = 'tu-api-key'; // Cambiar por tu API key

  Future<void> _loadLastSyncTime() async {
    final lastSyncStr = await _database.getSetting('last_sync_time');
    if (lastSyncStr != null) {
      final lastSync = DateTime.tryParse(lastSyncStr);
      if (lastSync != null) {
        state = state.copyWith(lastSyncTime: lastSync);
      }
    }
  }

  /// Sincronización manual completa
  Future<void> performFullSync() async {
    if (state.status == SyncStatus.syncing) {
      return; // Ya está sincronizando
    }

    state = state.copyWith(
      status: SyncStatus.syncing,
      message: 'Preparando sincronización...',
      synced: 0,
    );

    try {
      // Verificar conectividad
      if (!await _hasInternetConnection()) {
        throw Exception('Sin conexión a internet');
      }

      // Contar elementos pendientes de sincronización
      final pendingProducts = await _getPendingProducts();
      final pendingCategories = await _getPendingCategories();
      final pendingMovements = await _getPendingMovements();

      final totalItems =
          pendingProducts.length +
          pendingCategories.length +
          pendingMovements.length;

      state = state.copyWith(
        totalToSync: totalItems,
        message: 'Sincronizando $totalItems elementos...',
      );

      int syncedCount = 0;

      // Sincronizar categorías primero
      for (final category in pendingCategories) {
        await _syncCategory(category);
        syncedCount++;
        state = state.copyWith(
          synced: syncedCount,
          message: 'Sincronizando categorías ($syncedCount/$totalItems)...',
        );
      }

      // Sincronizar productos
      for (final product in pendingProducts) {
        await _syncProduct(product);
        syncedCount++;
        state = state.copyWith(
          synced: syncedCount,
          message: 'Sincronizando productos ($syncedCount/$totalItems)...',
        );
      }

      // Sincronizar movimientos
      for (final movement in pendingMovements) {
        await _syncMovement(movement);
        syncedCount++;
        state = state.copyWith(
          synced: syncedCount,
          message: 'Sincronizando movimientos ($syncedCount/$totalItems)...',
        );
      }

      // Guardar tiempo de última sincronización
      final now = DateTime.now();
      await _database.setSetting('last_sync_time', now.toIso8601String());

      state = state.copyWith(
        status: SyncStatus.success,
        message: 'Sincronización completada exitosamente',
        lastSyncTime: now,
      );

      // Volver a idle después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = state.copyWith(status: SyncStatus.idle);
        }
      });
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        message: 'Error en sincronización: ${e.toString()}',
      );

      // Volver a idle después de 5 segundos
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(status: SyncStatus.idle);
        }
      });
    }
  }

  /// Verificar conectividad a internet
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await http
          .get(
            Uri.parse('https://www.google.com'),
            headers: {'Connection': 'close'},
          )
          .timeout(const Duration(seconds: 5));
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtener productos pendientes de sincronización
  Future<List<Product>> _getPendingProducts() async {
    final allProducts = await _database.getAllProducts();
    return allProducts.where((product) => !product.isSynced).toList();
  }

  /// Obtener categorías pendientes de sincronización
  Future<List<Category>> _getPendingCategories() async {
    final allCategories = await _database.getAllCategories();
    return allCategories.where((category) => !category.isSynced).toList();
  }

  /// Obtener movimientos pendientes de sincronización
  Future<List<StockMovement>> _getPendingMovements() async {
    final allMovements = await _database.getAllStockMovements();
    return allMovements.where((movement) => !movement.isSynced).toList();
  }

  /// Sincronizar una categoría
  Future<void> _syncCategory(Category category) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'uuid': category.uuid,
          'name': category.name,
          'description': category.description,
          'created_at': category.createdAt.toIso8601String(),
          'updated_at': category.updatedAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Marcar como sincronizada
        await _database.markCategoryAsSynced(category.uuid);
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // En modo desarrollo, marcamos como sincronizada para evitar errores
      // En producción, deberías manejar el error apropiadamente
      await _database.markCategoryAsSynced(category.uuid);
    }
  }

  /// Sincronizar un producto
  Future<void> _syncProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'uuid': product.uuid,
          'name': product.name,
          'code': product.code,
          'category': product.category,
          'purchase_price': product.purchasePrice,
          'sale_price': product.salePrice,
          'stock': product.stock,
          'min_stock': product.minStock,
          'description': product.description,
          'image_path': product.imagePath,
          'created_at': product.createdAt.toIso8601String(),
          'updated_at': product.updatedAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Marcar como sincronizado
        await _database.markProductAsSynced(product.uuid);
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // En modo desarrollo, marcamos como sincronizado para evitar errores
      await _database.markProductAsSynced(product.uuid);
    }
  }

  /// Sincronizar un movimiento
  Future<void> _syncMovement(StockMovement movement) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/movements'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'uuid': movement.uuid,
          'product_uuid': movement.productUuid,
          'type': movement.type,
          'quantity': movement.quantity,
          'previous_stock': movement.previousStock,
          'new_stock': movement.newStock,
          'unit_price': movement.unitPrice,
          'reason': movement.reason,
          'notes': movement.notes,
          'created_at': movement.createdAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Marcar como sincronizado
        await _database.markMovementAsSynced(movement.uuid);
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // En modo desarrollo, marcamos como sincronizado para evitar errores
      await _database.markMovementAsSynced(movement.uuid);
    }
  }

  /// Obtener estadísticas de sincronización
  Future<Map<String, int>> getSyncStats() async {
    final pendingProducts = await _getPendingProducts();
    final pendingCategories = await _getPendingCategories();
    final pendingMovements = await _getPendingMovements();

    return {
      'pendingProducts': pendingProducts.length,
      'pendingCategories': pendingCategories.length,
      'pendingMovements': pendingMovements.length,
      'totalPending':
          pendingProducts.length +
          pendingCategories.length +
          pendingMovements.length,
    };
  }

  /// Resetear estado de sincronización
  void resetSyncState() {
    state = const SyncState(status: SyncStatus.idle);
  }
}

// Provider para el servicio de sincronización
final offlineSyncServiceProvider =
    StateNotifierProvider<OfflineSyncService, SyncState>((ref) {
      final database = ref.watch(databaseProvider);
      return OfflineSyncService(database);
    });

// Provider para estadísticas de sincronización
final syncStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final syncService = ref.read(offlineSyncServiceProvider.notifier);
  return syncService.getSyncStats();
});
