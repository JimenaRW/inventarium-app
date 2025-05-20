import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, int> topCategories;
  final List<Color> barColors;

  const CategoryChart({
    super.key,
    required this.topCategories,
    this.barColors = const [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ],
  });

  @override
  Widget build(BuildContext context) {
    if (topCategories.isEmpty) {
      return const Center(
        child: Text("No hay datos de categorías disponibles."),
      );
    }

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;
    int index = 0;

    topCategories.forEach((category, count) {
      barGroups.add(
        BarChartGroupData(
          x: index, // Usamos el índice como valor para el eje X
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color:
                  barColors[index %
                      barColors.length], // Asigna un color basado en el índice
              width: 22, // Ajusta el ancho de las barras si es necesario
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(show: false),
            ),
          ],
        ),
      );
      if (count > maxY) {
        maxY = count.toDouble();
      }
      index++;
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: true, horizontalInterval: 20),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Ocultamos las etiquetas del eje X
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY / 3).ceilToDouble(),
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == value.roundToDouble() && value > 0) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          maxY: maxY * 1.2, // Ajusta el maxY para que las etiquetas quepan
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.grey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} artículos',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
