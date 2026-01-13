import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../misc/template/template.dart';
import '../misc/workout/workout_log.dart';
import '../misc/workout/workout_bloc.dart';
import '../misc/workout/workout_event.dart';

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
    return _items.map((e) => "${e.sets.length} × ${e.name}").take(3).join(" • ");
  }

  List<String> _collectMuscles() {
    final muscles = <String>{};
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
    _items = widget.template.exercises
        .map((e) => WorkoutExercise(
              name: e.name,
              sets: List.generate(e.sets, (_) => WorkoutSet(reps: e.reps)),
            ))
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
            icon: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: () => setState(() => _stopwatch.isRunning ? _stopwatch.stop() : _stopwatch.start()),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(elapsed, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
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
                  Text(ex.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ...ex.sets.asMap().entries.map((entry) {
                    int i = entry.key;
                    var set = entry.value;
                    return Row(
                      children: [
                        SizedBox(width: 30, child: Text('${i + 1}')),
                        Expanded(
                          child: TextFormField(
                            initialValue: set.kg?.toString() ?? '',
                            decoration: const InputDecoration(hintText: 'kg'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => set.kg = double.tryParse(v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: set.reps?.toString() ?? '',
                            decoration: const InputDecoration(hintText: 'reps'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => set.reps = int.tryParse(v),
                          ),
                        ),
                        IconButton(
                          icon: Icon(set.done ? Icons.check_circle : Icons.radio_button_unchecked),
                          onPressed: () => setState(() => set.done = !set.done),
                        )
                      ],
                    );
                  }).toList(),
                  TextButton.icon(
                    onPressed: () => setState(() => ex.sets.add(WorkoutSet())),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Set"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final log = WorkoutLog(
            title: widget.template.name,
            when: DateTime.now(),
            durationSec: _stopwatch.elapsed.inSeconds,
            totalKg: _calculateTotalKg(),
            bestSet: _findBestSet(),
            setsDesc: _shortSummary(),
            muscles: _collectMuscles(),
            uid: '',
          );

          context.read<WorkoutBloc>().add(AddWorkoutLog(log));

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Workout saved!")),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }
}