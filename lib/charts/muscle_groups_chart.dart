import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../content.dart';
import '../misc/workout/workout_bloc.dart';
import '../misc/workout/workout_state.dart';

class MuscleGroupsChart extends StatelessWidget {
  const MuscleGroupsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        if (state is WorkoutLoading || state is WorkoutInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WorkoutLoaded) {
          final data = state.totalMuscleVolume;
          
          if (data.isEmpty) {
            return const Center(child: Text("No workout data yet"));
          }

          final bars = data.entries.toList();

          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: bars.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble() + 1,
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
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Text(
                            bars[index].key,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (int i = 0; i < bars.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: bars[i].value.toDouble(),
                        width: 16, 
                        color: muscleColors[bars[i].key] ?? Colors.blueAccent,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

        return const Center(child: Text("Unable to load chart data"));
      },
    );
  }
}