import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = <_WorkoutLog>[
      _WorkoutLog(
        title: 'Pull Day',
        when: DateTime(2025, 10, 20, 8, 42),
        setsDesc: '4 × Deadlift • 4 × Row',
        bestSet: '150 kg × 3',
        durationMin: 55,
        totalKg: 560,
      ),
      _WorkoutLog(
        title: 'Push Day (Hypertrophy)',
        when: DateTime(2025, 10, 18, 19, 5),
        setsDesc: '4 × Bench • 3 × Fly',
        bestSet: '70 kg × 8',
        durationMin: 54,
        totalKg: 720,
      ),
      _WorkoutLog(
        title: 'Legs + Core',
        when: DateTime(2025, 9, 29, 7, 15),
        setsDesc: '5 × Squat • 3 × RDL',
        bestSet: '110 kg × 5',
        durationMin: 63,
        totalKg: 895,
      ),
    ];

    final grouped = _groupByMonth(workouts);
    final longestStreak = _longestStreak(workouts.map((e) => e.when).toList());

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView.builder(
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
              // Month header line
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
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
              // Cards in this month
              for (final w in group.items) ...[
                _HistoryCard(w: w),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  List<_MonthGroup> _groupByMonth(List<_WorkoutLog> items) {
    items = List.of(items)..sort((a, b) => b.when.compareTo(a.when));
    final map = <String, List<_WorkoutLog>>{};
    for (final w in items) {
      final key = '${_monthName(w.when.month)} ${w.when.year}';
      (map[key] ??= []).add(w);
    }
    final groups = <_MonthGroup>[];
    map.forEach((k, v) => groups.add(_MonthGroup(label: k, items: v)));
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
      final prevNext = prev.add(const Duration(days: 1));
      if (DateTime(curr.year, curr.month, curr.day) ==
          DateTime(prevNext.year, prevNext.month, prevNext.day)) {
        cur++;
        if (cur > best) best = cur;
      } else {
        cur = 1;
      }
    }
    return best;
  }
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
          const Icon(Icons.local_fire_department),
          const SizedBox(width: 10),
          Text('Longest streak: $longestStreakDays day${longestStreakDays == 1 ? '' : 's'}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final _WorkoutLog w;
  const _HistoryCard({required this.w});

  String _weekdayShort(DateTime d) =>
      const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d.weekday - 1];

  String _monthNameShort(int m) =>
      const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  String _fmtDateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${_weekdayShort(d)} ${d.day} ${_monthNameShort(d.month)} ${d.year} at $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(w.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            _fmtDateTime(w.when),
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledBlock(
                  label: 'Sets',
                  child: Text(w.setsDesc, style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledBlock(
                  label: 'Best set',
                  alignRight: true,
                  child: Text(
                    w.bestSet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Stats row (duration • total weight)
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 6),
              Text('${w.durationMin}m'),
              const SizedBox(width: 16),
              const Icon(Icons.fitness_center, size: 18),
              const SizedBox(width: 6),
              Text('${_compactNumber(w.totalKg)} kg'),
            ],
          ),
        ],
      ),
    );
  }

  String _compactNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '$n';
  }
}

class _LabeledBlock extends StatelessWidget {
  final String label;
  final Widget child;
  final bool alignRight;
  const _LabeledBlock({required this.label, required this.child, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).textTheme.bodySmall?.color;
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: hint)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

//simple data models 

class _WorkoutLog {
  final String title;
  final DateTime when;
  final String setsDesc;
  final String bestSet;
  final int durationMin;
  final int totalKg; 
  const _WorkoutLog({
    required this.title,
    required this.when,
    required this.setsDesc,
    required this.bestSet,
    required this.durationMin,
    required this.totalKg,
  });
}

class _MonthGroup {
  final String label;
  final List<_WorkoutLog> items;
  const _MonthGroup({required this.label, required this.items});
}
