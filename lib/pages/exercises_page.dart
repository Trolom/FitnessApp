import 'package:flutter/material.dart';

import '../misc/exercise.dart';          // Exercise model
import '../content.dart';                // baseExercises
import '../misc/exercise_service.dart';  // Firestore access

// for the dropdown menu options when choosing for custom exercises
// NEW: broader muscle list
const kMuscleOptions = <String>[
  // Upper body – pushing
  'Chest',
  'Back'
  'Lower back',
  'Lats',
  'Legs',
  'Quads',
  'Hamstrings',
  'Glutes',
  'Calves',
  'Shoulders',
  'Delts',
  'Arms',
  'Biceps',
  'Triceps',
  'Forearms',
  'Core',
  'Abs',
  'Obliques',
  'Lower abs',
  'Hip flexors'
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
    final Set<String> selectedMuscles = { kMuscleOptions.first }; // for beter dropdown menu
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

                    //replaced the text input with a a better dropdown menu for the muscle group
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text('Muscle groups', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // open a checkbox dialog and update local state with the result
                        final result = await showDialog<Set<String>>(
                          context: context,
                          builder: (ctx) {
                            // local copy for interactive ticking inside the dialog
                            final temp = Set<String>.from(selectedMuscles);
                            return StatefulBuilder(
                              builder: (ctx, setSB) {
                                return AlertDialog(
                                  title: const Text('Select muscle groups'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        for (final m in kMuscleOptions)
                                          CheckboxListTile(
                                            title: Text(m),
                                            value: temp.contains(m),
                                            onChanged: (checked) {
                                              setSB(() {
                                                if (checked == true) {
                                                  temp.add(m);
                                                } else {
                                                  temp.remove(m);
                                                }
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx), // cancel
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        // ensure at least one is selected
                                        if (temp.isEmpty) temp.add(kMuscleOptions.first);
                                        Navigator.pop(ctx, temp);
                                      },
                                      child: const Text('Done'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );

                        if (result != null) {
                          setLocalState(() {
                            selectedMuscles
                              ..clear()
                              ..addAll(result);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        // show a compact preview of selected items
                        child: Text(
                          selectedMuscles.join(' • '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                      muscles: selectedMuscles.join(' • '),  //join the multiselect
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
