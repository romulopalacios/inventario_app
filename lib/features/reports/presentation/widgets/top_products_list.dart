import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/financial_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_components.dart';

class TopProductsList extends StatelessWidget {
  final List<ProductoMasVendido> productos;

  const TopProductsList({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Productos Más Vendidos',
            icon: Icons.emoji_events,
            iconColor: AppTheme.warningColor,
          ),
          if (productos.isEmpty)
            const EmptyState(
              title: 'Sin productos',
              icon: Icons.inventory_2_outlined,
              message: 'No hay ventas registradas',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productos.take(10).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final producto = productos[index];
                return _buildProductItem(context, producto, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    ProductoMasVendido producto,
    int index,
  ) {
    final theme = Theme.of(context);
    final position = index + 1;

    // Colores para las primeras 3 posiciones
    Color? badgeColor;
    IconData? badgeIcon;

    switch (position) {
      case 1:
        badgeColor = Colors.amber;
        badgeIcon = Icons.looks_one;
        break;
      case 2:
        badgeColor = Colors.grey;
        badgeIcon = Icons.looks_two;
        break;
      case 3:
        badgeColor = Colors.brown;
        badgeIcon = Icons.looks_3;
        break;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: badgeColor ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child:
              badgeIcon != null
                  ? Icon(badgeIcon, color: Colors.white, size: 24)
                  : Text(
                    '$position',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
        ),
      ),
      title: Text(
        producto.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.category, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  producto.categoria,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.shopping_cart, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${producto.cantidadVendida} unidades',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresos',
              style: TextStyle(fontSize: 10, color: theme.colorScheme.primary),
            ),
            Text(
              '\$${NumberFormat('#,##0.00').format(producto.ingresoTotal)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
