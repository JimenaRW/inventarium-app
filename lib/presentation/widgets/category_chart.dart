import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, int> topCategories;

  const CategoryChart({super.key, required this.topCategories});

  @override
  Widget build(BuildContext context) {
    if (topCategories.isEmpty) {
      return const Center(
        child: Text("No hay datos de categorías disponibles."),
      );
    }

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    topCategories.forEach((category, count) {
      barGroups.add(
        BarChartGroupData(
          x: barGroups.length, // Usamos el índice como valor para el eje X
          barRods: [
            BarChartRodData(toY: count.toDouble(), color: Colors.blueAccent),
          ],
        ),
      );
      if (count > maxY) {
        maxY = count.toDouble();
      }
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: true, horizontalInterval: 20),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topCategories.keys.length) {
                    return Text(
                      topCategories.keys.toList()[index],
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY / 3).ceilToDouble(),
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == value.roundToDouble()) {
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
          maxY: maxY * 1.1,
        ),
      ),
    );
  }
}
