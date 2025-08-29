import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/financial_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_components.dart';

class DailySalesChart extends StatelessWidget {
  final List<VentasDiarias> ventasDiarias;

  const DailySalesChart({super.key, required this.ventasDiarias});

  @override
  Widget build(BuildContext context) {
    if (ventasDiarias.isEmpty) {
      return const EmptyState(
        title: 'Sin datos',
        icon: Icons.show_chart,
        message: 'No hay datos disponibles',
      );
    }

    final maxValue = ventasDiarias
        .map((v) => v.ventas)
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxValue / 5,
          verticalInterval:
              ventasDiarias.length > 10 ? ventasDiarias.length / 5 : 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.grey, strokeWidth: 0.5);
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(color: Colors.grey, strokeWidth: 0.5);
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval:
                  ventasDiarias.length > 10
                      ? (ventasDiarias.length / 5).ceil().toDouble()
                      : 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < ventasDiarias.length) {
                  final date = ventasDiarias[value.toInt()].fecha;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: maxValue > 0 ? maxValue / 4 : 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${NumberFormat('#,##0').format(value)}',
                  style: const TextStyle(fontSize: 9),
                );
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
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (ventasDiarias.length - 1).toDouble(),
        minY: 0,
        maxY: maxValue * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots:
                ventasDiarias.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.ventas);
                }).toList(),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                if (spot.spotIndex < ventasDiarias.length) {
                  final venta = ventasDiarias[spot.spotIndex];
                  return LineTooltipItem(
                    '${DateFormat('dd/MM/yyyy').format(venta.fecha)}\n'
                    'Ventas: \$${NumberFormat('#,##0.00').format(venta.ventas)}\n'
                    'Productos: ${venta.cantidadProductos}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
