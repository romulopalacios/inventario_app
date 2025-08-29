import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/financial_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_components.dart';

class FinancialSummaryCard extends StatelessWidget {
  final FinancialData data;

  const FinancialSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Resumen Financiero',
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Ventas Totales',
                  value:
                      '\$${NumberFormat('#,##0.00').format(data.totalVentas)}',
                  icon: Icons.shopping_cart,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MetricCard(
                  title: 'Compras Totales',
                  value:
                      '\$${NumberFormat('#,##0.00').format(data.totalCompras)}',
                  icon: Icons.shopping_bag,
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Ganancias Brutas',
                  value:
                      '\$${NumberFormat('#,##0.00').format(data.gananciasBrutas)}',
                  icon: Icons.trending_up,
                  color:
                      data.gananciasBrutas >= 0
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MetricCard(
                  title: 'Total Productos',
                  value: '${data.totalProductos}',
                  icon: Icons.inventory_2,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.small,
            ),
            child: Column(
              children: [
                Text(
                  'Estado del Inventario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInventoryStatus(
                      'Con Stock',
                      '${data.productosConStock}',
                      AppTheme.successColor,
                    ),
                    _buildInventoryStatus(
                      'Sin Stock',
                      '${data.productosSinStock}',
                      data.productosSinStock > 0
                          ? AppTheme.errorColor
                          : Colors.grey,
                    ),
                    _buildInventoryStatus(
                      'Valor Total',
                      '\$${NumberFormat('#,##0').format(data.valorInventario)}',
                      AppTheme.secondaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatus(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
