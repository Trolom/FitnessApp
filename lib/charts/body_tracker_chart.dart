import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BodyTrackerChart extends StatelessWidget {
  const BodyTrackerChart({super.key});

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
          return const Center(child: Text('No weight data yet'));
        }

        final docs = snapshot.data!.docs;

        // date (truncated to day) -> weightKg
        final Map<DateTime, double> weightByDay = {};

        for (final doc in docs) {
          final data = doc.data();
          if (!data.containsKey('date')) continue;

          final ts = data['date'] as Timestamp;
          final dt = ts.toDate();
          final day = DateTime(dt.year, dt.month, dt.day);

          if (data.containsKey('weightKg')) {
            final w = (data['weightKg'] as num).toDouble();
            weightByDay[day] = w; // one doc per day – last wins
          }
        }

        if (weightByDay.isEmpty) {
          return const Center(child: Text('No weight data yet'));
        }

        final sortedDays = weightByDay.keys.toList()..sort();
        final firstDay = sortedDays.first;
        final lastDay = sortedDays.last;

        final List<DateTime> days = [];
        final List<double?> raw = [];

        for (DateTime d = firstDay;
            !d.isAfter(lastDay);
            d = d.add(const Duration(days: 1))) {
          days.add(d);
          raw.add(weightByDay[d]); // null if missing
        }

        final knownIndices = <int>[];
        for (int i = 0; i < raw.length; i++) {
          if (raw[i] != null) knownIndices.add(i);
        }

        if (knownIndices.isEmpty) {
          return const Center(child: Text('No weight data yet'));
        }

        final List<double> interp = List<double>.filled(raw.length, 0);

        if (knownIndices.length == 1) {
          final idx = knownIndices.first;
          interp[idx] = raw[idx]!;
        } else {
          for (int s = 0; s < knownIndices.length - 1; s++) {
            final i0 = knownIndices[s];
            final i1 = knownIndices[s + 1];
            final v0 = raw[i0]!;
            final v1 = raw[i1]!;
            final span = i1 - i0;

            for (int k = 0; k <= span; k++) {
              final t = k / span;
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
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
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