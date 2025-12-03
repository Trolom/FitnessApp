import 'package:flutter/material.dart';
import '../misc/workout/workout_log.dart';
import '../misc/history_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../misc/workout/workout_providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),

      body: workoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading history: $err")),
        data: (workouts) {
          
          if (workouts.isEmpty) {
            return const Center(child: Text("No workouts yet."));
          }

          final grouped = _groupByMonth(workouts);
          final longestStreak = _longestStreak(workouts.map((w) => w.when).toList());

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: grouped.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StreakBanner(longestStreakDays: longestStreak),
                );
              }

              final group = grouped[i - 1];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.label,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                        Text(
                          '${group.items.length} workout${group.items.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Workout Cards
                  for (final w in group.items) ...[
                    HistoryCard(w: w),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<MonthGroup> _groupByMonth(List<WorkoutLog> items) {
    // sort logic is redundant because provider does it, but kept for safety
    items = List.of(items)..sort((a, b) => b.when.compareTo(a.when));

    final map = <String, List<WorkoutLog>>{};

    for (final w in items) {
      final key = '${_monthName(w.when.month)} ${w.when.year}';
      (map[key] ??= []).add(w);
    }

    final groups = <MonthGroup>[];
    map.forEach((k, v) => groups.add(MonthGroup(label: k, items: v)));

    groups.sort((a, b) => b.items.first.when.compareTo(a.items.first.when));
    return groups;
  }

  String _monthName(int m) => const [
        'January','February','March','April','May','June',
        'July','August','September','October','November','December'
      ][m - 1];
  int _longestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final set = {for (final d in dates) DateTime(d.year, d.month, d.day)};
    final sorted = set.toList()..sort();

    int best = 1, cur = 1;

    for (var i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];
      final nextDay = prev.add(const Duration(days: 1));

      if (DateTime(curr.year, curr.month, curr.day) ==
          DateTime(nextDay.year, nextDay.month, nextDay.day)) {
        cur++;
        if (cur > best) best = cur;
      } else {
        cur = 1;
      }
    }
    return best;
  }
}

class MonthGroup {
  final String label;
  final List<WorkoutLog> items;
  MonthGroup({required this.label, required this.items});
}

class _StreakBanner extends StatelessWidget {
  final int longestStreakDays;
  const _StreakBanner({required this.longestStreakDays});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 10),
          Text(
            'Longest streak: $longestStreakDays day${longestStreakDays == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}