import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../mock_data.dart';


/// You can use it in two ways:
/// 1) Provide `data` directly: a map of muscle -> volume.
/// 2) Provide `date` AND `muscles` (the whole per-day map), and it will look up that day.
///
/// If both are provided, `data` takes precedence.
class DayMusclePie extends StatelessWidget {
  final Map<String, int>? data; 
  final DateTime? date; 
  final Map<DateTime, Map<String, int>>? muscles;

  const DayMusclePie({
    super.key,
    this.data,
    this.date,
    this.muscles,
  });

  Map<String, int> _resolveData() {
    if (data != null) return data!;
    if (date != null && muscles != null) {
      final key = DateTime(date!.year, date!.month, date!.day);
      return muscles![key] ?? const {};
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final map = _resolveData();

    if (map.isEmpty) {
      return const Center(child: Text('No workout logged for this day'));
    }

    final total = map.values.fold<int>(0, (a, b) => a + b).clamp(0, 1 << 31);
    final sections = map.entries.map((e) {
      final color = muscleColors[e.key] ?? Colors.grey;
      final value = e.value.toDouble();
      final percent = total == 0 ? 0 : (value / total * 100);
      return PieChartSectionData(
        value: value,
        title: '${percent.toStringAsFixed(0)}%\n${e.key}',
        radius: 70,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        color: color,
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: map.keys.map((k) {
            final c = muscleColors[k] ?? Colors.grey;
            final pct = total == 0 ? 0 : (map[k]! / total * 100);
            return Chip(
              avatar: CircleAvatar(backgroundColor: c, radius: 6),
              label: Text('$k • ${pct.toStringAsFixed(0)}%'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
