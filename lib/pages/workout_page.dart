// lib/pages/workout_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../template.dart';

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

class WorkoutPage extends StatefulWidget {
  final Template template;
  const WorkoutPage({super.key, required this.template});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late List<WorkoutExercise> _items;
  late Stopwatch _stopwatch;
  Timer? _ticker;

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => ex.sets.add(WorkoutSet())),
                      icon: const Icon(Icons.add),
                      label: const Text('Add set'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout saved (stub).')),
          );
          await Future.delayed(const Duration(seconds: 2));

          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }
}
