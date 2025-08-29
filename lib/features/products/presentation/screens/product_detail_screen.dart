import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/reactive_providers.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/product_image_gallery.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final movementsAsync = ref.watch(stockMovementsProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  context.go('/products/$productId/edit');
                  break;
                case 'delete':
                  _showDeleteDialog(context, ref);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Producto no encontrado'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productDetailProvider(productId));
              ref.invalidate(stockMovementsProvider(productId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(context, ref, product),
                  const SizedBox(height: 16),
                  ProductImageGallery(
                    productId: productId,
                    productName: product.name,
                    allowEdit: true,
                  ),
                  const SizedBox(height: 16),
                  _buildStockSection(context, product),
                  const SizedBox(height: 16),
                  _buildMovementsSection(context, movementsAsync),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error al cargar producto: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(productDetailProvider(productId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildProductInfo(
    BuildContext context,
    WidgetRef ref,
    dynamic product,
  ) {
    final formatter = NumberFormat.currency(locale: 'es_ES', symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Product image or placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<List<String>>(
                    future: ref.watch(
                      productImagesProvider(product.uuid).future,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(snapshot.data!.first),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                          ),
                        );
                      } else {
                        return Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey[400],
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (product.code != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Código: ${product.code}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                      if (product.category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (product.description != null) ...[
              const SizedBox(height: 16),
              Text(
                'Descripción',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(product.description),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Price information
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Precio Compra',
                    formatter.format(product.purchasePrice),
                    Icons.money_off,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Precio Venta',
                    formatter.format(product.salePrice),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection(BuildContext context, dynamic product) {
    final isLowStock = product.stock <= product.minStock;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  color: isLowStock ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Stock Bajo',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Stock Actual',
                    '${product.stock}',
                    Icons.inventory_2,
                    isLowStock ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Stock Mínimo',
                    '${product.minStock}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => context.go('/products/$productId/stock-movement'),
                    icon: const Icon(Icons.add),
                    label: const Text('Entrada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => context.go('/products/$productId/stock-movement'),
                    icon: const Icon(Icons.remove),
                    label: const Text('Salida'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementsSection(
    BuildContext context,
    AsyncValue<List<dynamic>> movementsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial de Movimientos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            movementsAsync.when(
              data: (movements) {
                if (movements.isEmpty) {
                  return const Text(
                    'No hay movimientos registrados',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Column(
                  children:
                      movements
                          .take(5)
                          .map((movement) => _buildMovementItem(movement))
                          .toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error:
                  (error, stackTrace) =>
                      Text('Error al cargar movimientos: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementItem(dynamic movement) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    Color typeColor;
    IconData typeIcon;
    String typeText;

    switch (movement.type) {
      case 'entrada':
        typeColor = Colors.green;
        typeIcon = Icons.add;
        typeText = 'Entrada';
        break;
      case 'salida':
        typeColor = Colors.red;
        typeIcon = Icons.remove;
        typeText = 'Salida';
        break;
      case 'ajuste':
        typeColor = Colors.blue;
        typeIcon = Icons.edit;
        typeText = 'Ajuste';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.help;
        typeText = movement.type;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: typeColor.withOpacity(0.2),
        child: Icon(typeIcon, color: typeColor, size: 20),
      ),
      title: Text(typeText),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cantidad: ${movement.quantity}'),
          Text('${movement.previousStock} → ${movement.newStock}'),
          if (movement.reason != null) Text('Motivo: ${movement.reason}'),
          Text(dateFormat.format(movement.createdAt)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    ConfirmationDialog.show(
      context: context,
      title: 'Eliminar Producto',
      content:
          '¿Estás seguro de que quieres eliminar este producto? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      confirmColor: Colors.red,
      icon: Icons.delete_forever,
      onConfirm: () async {
        try {
          await ref.read(deleteProductProvider(productId).future);

          // Invalidate providers to refresh data
          ref.invalidate(productsProvider);
          ref.invalidate(filteredProductsProvider);
          ref.invalidate(inventoryStatsProvider);
          ref.invalidate(lowStockProductsProvider);

          if (context.mounted) {
            context.go('/products');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto eliminado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
}
