import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CaloriesChart extends StatelessWidget {
  const CaloriesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Not logged in'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('dailyLogs')
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data yet'));
        }

        final docs = snapshot.data!.docs;

        // date (truncated to day) -> calories
        final Map<DateTime, int> caloriesByDay = {};

        for (final doc in docs) {
          final data = doc.data();
          if (!data.containsKey('date')) continue;

          final ts = data['date'] as Timestamp;
          final dt = ts.toDate();
          final day = DateTime(dt.year, dt.month, dt.day);

          if (data.containsKey('calories')) {
            final calories = (data['calories'] as num).toInt();
            caloriesByDay[day] = calories; // one doc per day – last wins
          }
        }

        if (caloriesByDay.isEmpty) {
          return const Center(child: Text('No data yet'));
        }

        // continuous range from first log day to last log day
        final sortedDays = caloriesByDay.keys.toList()..sort();
        final firstDay = sortedDays.first;
        final lastDay = sortedDays.last;

        final List<DateTime> days = [];
        final List<double?> raw = []; // null = missing day

        for (DateTime d = firstDay;
            !d.isAfter(lastDay);
            d = d.add(const Duration(days: 1))) {
          days.add(d);
          raw.add(
            caloriesByDay.containsKey(d)
                ? caloriesByDay[d]!.toDouble()
                : null,
          );
        }

        // find indices with real values
        final knownIndices = <int>[];
        for (int i = 0; i < raw.length; i++) {
          if (raw[i] != null) knownIndices.add(i);
        }

        if (knownIndices.isEmpty) {
          return const Center(child: Text('No data yet'));
        }

        // if only one real point, no interpolation possible
        final List<double> interp = List<double>.filled(raw.length, 0);

        if (knownIndices.length == 1) {
          final idx = knownIndices.first;
          interp[idx] = raw[idx]!;
        } else {
          // interpolate between each pair of known indices
          for (int s = 0; s < knownIndices.length - 1; s++) {
            final i0 = knownIndices[s];
            final i1 = knownIndices[s + 1];
            final v0 = raw[i0]!;
            final v1 = raw[i1]!;
            final span = i1 - i0;

            for (int k = 0; k <= span; k++) {
              final t = k / span; // 0..1
              interp[i0 + k] = v0 + (v1 - v0) * t;
            }
          }
        }

        final spots = <FlSpot>[
          for (int i = 0; i < interp.length; i++)
            FlSpot(i.toDouble(), interp[i]),
        ];

        return LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    // only integer positions
                    if (value % 1 != 0) {
                      return const SizedBox.shrink();
                    }
                    final index = value.toInt();
                    if (index < 0 || index >= days.length) {
                      return const SizedBox.shrink();
                    }
                    final d = days[index];
                    return Text(
                      '${d.day}/${d.month}',
                      style: const TextStyle(fontSize: 10),
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
            gridData: const FlGridData(show: true),
            minX: 0,
            maxX: (spots.length - 1).toDouble(),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                dotData: const FlDotData(show: false),
                barWidth: 3,
              ),
            ],
          ),
        );
      },
    );
  }
}