import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../mock_data.dart';


class BodyTrackerChart extends StatelessWidget {
  const BodyTrackerChart({super.key});


  @override
  Widget build(BuildContext context) {
    final spots = List.generate(mockBodyWeight.length, (i) => FlSpot(i.toDouble(), mockBodyWeight[i].toDouble()));


    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            dotData: const FlDotData(show: false),
            barWidth: 3,
            spots: spots,
          )
        ],
      ),
    );
  }
}