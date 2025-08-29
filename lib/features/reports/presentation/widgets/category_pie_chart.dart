import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_components.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> ventasPorCategoria;

  const CategoryPieChart({super.key, required this.ventasPorCategoria});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.ventasPorCategoria.isEmpty) {
      return const EmptyState(
        title: 'Sin datos',
        icon: Icons.pie_chart,
        message: 'No hay datos disponibles',
      );
    }

    final total = widget.ventasPorCategoria.values.reduce((a, b) => a + b);
    final colors = _generateColors(widget.ventasPorCategoria.length);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildPieChartSections(colors, total),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 16, runSpacing: 8, children: _buildLegend(colors)),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<Color> colors,
    double total,
  ) {
    return widget.ventasPorCategoria.entries.map((entry) {
      final index = widget.ventasPorCategoria.keys.toList().indexOf(entry.key);
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 80.0 : 60.0;
      final percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(List<Color> colors) {
    return widget.ventasPorCategoria.entries.map((entry) {
      final index = widget.ventasPorCategoria.keys.toList().indexOf(entry.key);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${NumberFormat('#,##0.00').format(entry.value)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      );
    }).toList();
  }

  List<Color> _generateColors(int count) {
    final baseColors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      colors.add(baseColors[i % baseColors.length]);
    }

    return colors;
  }
}
