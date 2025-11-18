import 'package:flutter/material.dart';

import '../misc/exercise.dart';          // Exercise model
import '../content.dart';                // baseExercises
import '../misc/exercise_service.dart';  // Firestore access

// for the dropdown menu options when choosing for custom exercises
const kMuscleOptions = <String>[
  'Chest',
  'Back',
  'Legs',
  'Shoulders',
  'Arms',
  'Core',
  'Glutes',
  'Quads',
  'Hamstrings',
  'Calves',
];

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Merge base exercises + user exercises after both streams resolve
  Stream<List<Exercise>> _allExercisesStream() {
    return ExerciseService.userExercisesStream().map((userList) {
      return [
        ...baseExercises,
        ...userList,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),

      body: StreamBuilder<List<Exercise>>(
        stream: _allExercisesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final query = _searchCtrl.text.trim().toLowerCase();

          final filtered = all.where((ex) {
            return query.isEmpty ||
                ex.name.toLowerCase().contains(query) ||
                ex.muscles.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              // SEARCH FIELD
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search exercises (e.g. push, chest)',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            _ExerciseTile(ex: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  // ---------------- ADD CUSTOM EXERCISE ----------------

  void _openAddDialog() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();

    String unit = 'reps';
    String selectedMuscle = kMuscleOptions.first; // default dropdown selection

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder( //local state for the dialog
          builder: (ctx, setLocalState) {
            return AlertDialog(
              title: const Text('Add Custom Exercise'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),

                    //replaced the text input with a dropdown menu for the muscle group
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Muscle group'),
                      initialValue: selectedMuscle,
                      items: kMuscleOptions
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setLocalState(() => selectedMuscle = v!), //to only render the dialog and not the whole page when updated
                    ),

                    TextField(
                      controller: setsCtrl,
                      decoration: const InputDecoration(labelText: 'Sets'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: repsCtrl,
                      decoration: const InputDecoration(labelText: 'Reps / Seconds'),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<String>(
                      value: unit, // this is fine (not the FormField version)
                      items: const [
                        DropdownMenuItem(value: 'reps', child: Text('Reps')),
                        DropdownMenuItem(value: 'sec', child: Text('Seconds')),
                      ],
                      onChanged: (v) => setLocalState(() => unit = v!), // same here as above
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    final ex = Exercise(
                      name: nameCtrl.text.trim(),
                      muscles: selectedMuscle,
                      sets: int.tryParse(setsCtrl.text) ?? 0,
                      reps: int.tryParse(repsCtrl.text) ?? 0,
                      unit: unit,
                      isCustom: true,
                    );
                    await ExerciseService.addCustomExercise(ex);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// -------------------------- UI COMPONENTS --------------------------

class _ExerciseTile extends StatelessWidget {
  final Exercise ex;
  const _ExerciseTile({required this.ex});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(ex.name[0]),
        ),

        title: Row(
          children: [
            Text(ex.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (ex.isCustom) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Custom",
                  style: TextStyle(fontSize: 10),
                ),
              )
            ],
          ],
        ),

        subtitle: Text(ex.muscles),

        trailing: Text(
          ex.unit == 'sec'
              ? '${ex.reps} sec'
              : '${ex.sets}×${ex.reps}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),

        onTap: () => _openDetails(context),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),

      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ex.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

            const SizedBox(height: 6),
            Text(ex.muscles),

            const SizedBox(height: 12),
            Text(
              ex.unit == 'sec'
                  ? '${ex.reps} seconds'
                  : '${ex.sets} sets × ${ex.reps} reps',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            //removed the "Add to today button" and replaced with close
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48),
            SizedBox(height: 8),
            Text("No exercises found."),
          ],
        ),
      ),
    );
  }
}
