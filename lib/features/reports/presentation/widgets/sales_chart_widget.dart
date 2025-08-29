import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_components.dart';

class SalesChartWidget extends StatelessWidget {
  final double totalVentas;
  final double totalCompras;
  final double ganancias;

  const SalesChartWidget({
    super.key,
    required this.totalVentas,
    required this.totalCompras,
    required this.ganancias,
  });

  @override
  Widget build(BuildContext context) {
    if (totalVentas == 0 && totalCompras == 0 && ganancias == 0) {
      return const EmptyState(
        title: 'Sin datos',
        icon: Icons.bar_chart,
        message: 'No hay datos disponibles',
      );
    }

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  [
                    totalVentas,
                    totalCompras,
                    ganancias,
                  ].reduce((a, b) => a > b ? a : b) *
                  1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String value;
                    String label;

                    switch (group.x) {
                      case 0:
                        value = NumberFormat('#,##0.00').format(totalVentas);
                        label = 'Ventas';
                        break;
                      case 1:
                        value = NumberFormat('#,##0.00').format(totalCompras);
                        label = 'Compras';
                        break;
                      case 2:
                        value = NumberFormat('#,##0.00').format(ganancias);
                        label = 'Ganancias';
                        break;
                      default:
                        value = '';
                        label = '';
                    }

                    return BarTooltipItem(
                      '$label\n\$$value',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${NumberFormat('#,##0').format(value)}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text(
                            'Ventas',
                            style: TextStyle(fontSize: 12),
                          );
                        case 1:
                          return const Text(
                            'Compras',
                            style: TextStyle(fontSize: 12),
                          );
                        case 2:
                          return const Text(
                            'Ganancias',
                            style: TextStyle(fontSize: 12),
                          );
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: totalVentas,
                      color: AppTheme.successColor,
                      width: 25,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: totalCompras,
                      color: AppTheme.warningColor,
                      width: 25,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: ganancias,
                      color:
                          ganancias >= 0
                              ? AppTheme.primaryColor
                              : AppTheme.errorColor,
                      width: 25,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Ventas', AppTheme.successColor),
            _buildLegendItem('Compras', AppTheme.warningColor),
            _buildLegendItem(
              'Ganancias',
              ganancias >= 0 ? AppTheme.primaryColor : AppTheme.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
