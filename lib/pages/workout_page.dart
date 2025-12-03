import 'dart:async';
import 'package:flutter/material.dart';
import '../misc/template/template.dart';
import '../misc/workout/workout_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../misc/workout/workout_providers.dart';

class WorkoutSet {
  double? kg;
  int? reps;
  bool done;
  WorkoutSet({this.kg, this.reps, this.done = false});
}

class WorkoutExercise {
  final String name;
  final List<WorkoutSet> sets;
  WorkoutExercise({required this.name, required this.sets});
}

// Changed to ConsumerStatefulWidget to access "ref"
class WorkoutPage extends ConsumerStatefulWidget {
  final Template template;
  const WorkoutPage({super.key, required this.template});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  late List<WorkoutExercise> _items;
  late Stopwatch _stopwatch;
  Timer? _ticker;

  int _calculateTotalKg() {
    int total = 0;
    for (var ex in _items) {
      for (var s in ex.sets) {
        if (s.kg != null && s.reps != null) {
          total += (s.kg! * s.reps!).round();
        }
      }
    }
    return total;
  }

  String _findBestSet() {
    double best = 0;
    String desc = "-";

    for (var ex in _items) {
      for (var s in ex.sets) {
        if (s.kg != null && s.reps != null) {
          final volume = s.kg! * s.reps!;
          if (volume > best) {
            best = volume;
            desc = "${s.kg!.toStringAsFixed(0)} kg × ${s.reps}";
          }
        }
      }
    }
    return desc;
  }

  String _shortSummary() {
    return _items
        .map((e) => "${e.sets.length} × ${e.name}")
        .take(3)
        .join(" • ");
  }

  List<String> _collectMuscles() {
    final muscles = <String>{}; // use Set to avoid duplicates

    for (final block in widget.template.exercises) {
      for (final m in block.muscles) {
        muscles.add(m);
      }
    }

    return muscles.toList();
  }


  @override
  void initState() {
    super.initState();
    // Build editable workout from the template defaults
    _items = widget.template.exercises
        .map(
          (e) => WorkoutExercise(
            name: e.name,
            sets: List.generate(e.sets, (_) => WorkoutSet(reps: e.reps)),
          ),
        )
        .toList();

    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _formatElapsed(_stopwatch.elapsed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          IconButton(
            tooltip: _stopwatch.isRunning ? 'Pause timer' : 'Start timer',
            icon: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                if (_stopwatch.isRunning) {
                  _stopwatch.stop();
                } else {
                  _stopwatch.start();
                }
              });
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                elapsed,
                style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        itemBuilder: (context, idx) {
          final ex = _items[idx];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ex.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Header row
                  Row(
                    children: const [
                      SizedBox(width: 45, child: Text('#', textAlign: TextAlign.center)),
                      SizedBox(width: 100, child: Text('KG', textAlign: TextAlign.center)),
                      SizedBox(width: 100, child: Text('Reps', textAlign: TextAlign.center)),
                      SizedBox(width: 100, child: Text('Done', textAlign: TextAlign.center)),
                    ],
                  ),
                  const Divider(height: 12),

                  // Set rows
                  ...List.generate(ex.sets.length, (i) {
                    final set = ex.sets[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 45,
                            child: Text('${i + 1}', textAlign: TextAlign.center),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: set.kg?.toString() ?? '',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(hintText: 'kg'),
                              onChanged: (v) => set.kg = double.tryParse(v.replaceAll(',', '.')),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: set.reps?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(hintText: 'reps'),
                              onChanged: (v) => set.reps = int.tryParse(v),
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            tooltip: 'Mark done',
                            onPressed: () => setState(() => set.done = !set.done),
                            icon: Icon(
                              set.done ? Icons.check_circle : Icons.radio_button_unchecked,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon
                        (onPressed: () => setState(() => ex.sets.add(WorkoutSet())),
                        icon:const Icon(Icons.add),
                        label: const Text("Add set")
                        ),
                      TextButton.icon(
                        onPressed: () => setState(() {
                          if (ex.sets.isNotEmpty) ex.sets.removeLast();
                        }),
                        icon: const Icon(Icons.remove),
                        label: const Text("Remove set")
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final totalKg = _calculateTotalKg();
          final bestSet = _findBestSet();
          final setsDesc = _shortSummary();
          final duration = _stopwatch.elapsed.inSeconds;

          final muscles = _collectMuscles();

          final log = WorkoutLog(
            title: widget.template.name,
            when: DateTime.now(),
            durationSec: duration,
            totalKg: totalKg,
            bestSet: bestSet,
            setsDesc: setsDesc,
            muscles: muscles,
            // Sync status will be handled by the provider (defaults to 'pending')
          );

          // --- CHANGE: USE THE OFFLINE-FIRST PROVIDER ---
          await ref.read(workoutLogsProvider.notifier).addLog(log);
          
          if (!mounted) return;
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Workout saved!")));
        },
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      )
    );
  }
}