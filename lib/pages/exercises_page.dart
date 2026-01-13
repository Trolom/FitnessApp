import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Change to BLoC

import '../misc/exercise/exercise.dart';
import '../content.dart';
import '../misc/exercise/exercise_bloc.dart';
import '../misc/exercise/exercise_event.dart';
import '../misc/exercise/exercise_state.dart';

// 1. Change to standard StatefulWidget
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      
      // 2. Use BlocBuilder instead of allExercisesAsync.when
      body: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, state) {
          if (state.status == ExerciseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.status == ExerciseStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          final query = _searchCtrl.text.trim().toLowerCase();
          final all = state.allExercises;

          final filtered = all.where((ex) {
            return query.isEmpty ||
                ex.name.toLowerCase().contains(query) ||
                ex.muscles.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
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
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ExerciseTile(ex: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  // ---------------- ADD CUSTOM EXERCISE ----------------

  void _openAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();

    String unit = 'reps';
    final Set<String> selectedMuscles = { kMuscleOptions.first }; 
    
    showDialog(
      context: context,
      builder: (dialogCtx) { // Use a specific context for the dialog
        return StatefulBuilder( 
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
                    // ... (Muscle groups section remains identical to your original code)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text('Muscle groups', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final result = await showDialog<Set<String>>(
                          context: context,
                          builder: (ctx) {
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
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                    FilledButton(
                                      onPressed: () {
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
                        if (result != null) setLocalState(() => selectedMuscles..clear()..addAll(result));
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                        child: Text(selectedMuscles.join(' • ')),
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
                      value: unit,
                      items: const [
                        DropdownMenuItem(value: 'reps', child: Text('Reps')),
                        DropdownMenuItem(value: 'sec', child: Text('Seconds')),
                      ],
                      onChanged: (v) => setLocalState(() => unit = v!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () {
                    final newEx = Exercise(
                      name: nameCtrl.text.trim(),
                      muscles: selectedMuscles.join(' • '),
                      sets: int.tryParse(setsCtrl.text) ?? 0,
                      reps: int.tryParse(repsCtrl.text) ?? 0,
                      unit: unit,
                      isCustom: true,
                    );
                    
                    // 3. CRITICAL CHANGE: Dispatch event to BLoC
                    context.read<ExerciseBloc>().add(AddExerciseEvent(newEx));
                    
                    Navigator.pop(context);
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
        leading: CircleAvatar(child: Text(ex.name[0])),
        title: Row(
          children: [
            Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (ex.isCustom) ...[
              const SizedBox(width: 6),
              _StatusTag(label: "Custom", color: scheme.primaryContainer),
            ],
            if (ex.syncStatus == 'pending') ...[
              const SizedBox(width: 6),
              const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.orange), 
            ],
            if (ex.syncStatus == 'error') ...[
              const SizedBox(width: 6),
              const Icon(Icons.error, size: 16, color: Colors.red),
            ],
          ],
        ),
        subtitle: Text(ex.muscles),
        trailing: Text(
          ex.unit == 'sec' ? '${ex.reps} sec' : '${ex.sets}×${ex.reps}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onTap: () => _showDetails(context),
      ),
    );
  }

  void _showDetails(BuildContext context) {
     showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ex.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(ex.muscles),
            const SizedBox(height: 12),
            Text(ex.unit == 'sec' ? '${ex.reps} seconds' : '${ex.sets} sets × ${ex.reps} reps',
              style: const TextStyle(fontWeight: FontWeight.w600)),
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

class _StatusTag extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48),
          SizedBox(height: 8),
          Text("No exercises found."),
        ],
      ),
    );
  }
}