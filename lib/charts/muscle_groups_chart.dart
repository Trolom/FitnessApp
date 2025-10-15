import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../mock_data.dart';


class MuscleGroupsChart extends StatelessWidget {
  const MuscleGroupsChart({super.key});


  @override
  Widget build(BuildContext context) {
    final bars = mockMuscleGroups.entries.toList();


    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= bars.length) return const SizedBox.shrink();
                return Transform.rotate(
                  angle: -0.7,
                  child: Text(bars[idx].key, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        barGroups: [
          for (var i = 0; i < bars.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: bars[i].value.toDouble(), width: 12)])
        ],
      ),
    );
  }
}
