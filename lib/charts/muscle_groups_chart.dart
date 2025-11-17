import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../misc/workout_service.dart';
import '../content.dart';

class MuscleGroupsChart extends StatelessWidget {
  const MuscleGroupsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: WorkoutService.totalMuscleVolumeStream(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snap.data!;
        if (data.isEmpty) {
          return const Center(child: Text("No workout data yet"));
        }

        final bars = data.entries.toList();

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 28),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= bars.length) {
                      return const SizedBox.shrink();
                    }

                    return Transform.rotate(
                      angle: -0.7,
                      child: Text(
                        bars[index].key,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: true),
            barGroups: [
              for (int i = 0; i < bars.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: bars[i].value.toDouble(),
                      width: 12,
                      color: muscleColors[bars[i].key] ?? Colors.grey,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
