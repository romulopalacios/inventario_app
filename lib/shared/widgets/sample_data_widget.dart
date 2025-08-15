import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/sample_data_service.dart';
import '../../core/services/inventory_service.dart';
import '../../core/providers/database_providers.dart';

class SampleDataWidget extends ConsumerWidget {
  const SampleDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return products.when(
      data: (productsList) {
        if (productsList.isEmpty) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Bienvenido a Inventario Fácil!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu inventario está vacío. Puedes agregar productos manualmente o cargar algunos datos de ejemplo para comenzar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _loadSampleData(context, ref),
                          icon: const Icon(Icons.download),
                          label: const Text('Cargar Datos de Ejemplo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addFirstProduct(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Producto'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Future<void> _loadSampleData(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Cargando datos de ejemplo...'),
              ],
            ),
          ),
    );

    try {
      final productService = ref.read(productServiceProvider);
      final sampleDataService = SampleDataService(productService);

      // Create sample categories first
      await sampleDataService.createSampleCategories();

      // Then create sample products
      await sampleDataService.createSampleData();

      // Refresh the data
      ref.invalidate(productsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(inventoryStatsProvider);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos de ejemplo cargados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addFirstProduct(BuildContext context) {
    // Navigate to add product screen using go_router
    context.go('/products/add');
  }
}
