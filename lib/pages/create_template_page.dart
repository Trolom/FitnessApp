import 'package:flutter/material.dart';
import '../misc/template.dart';
import '../misc/template_service.dart';
import '../content.dart';
import '../misc/exercise_block.dart';
//
import '../misc/exercise.dart';
import '../misc/exercise_service.dart'; 

class CreateTemplatePage extends StatefulWidget {
  const CreateTemplatePage({super.key});

  @override
  State<CreateTemplatePage> createState() => _CreateTemplatePageState();
}

class _CreateTemplatePageState extends State<CreateTemplatePage> {
  final _nameCtrl = TextEditingController();
  final List<ExerciseBlock> _blocks = [];

    Stream<List<Exercise>> _allExercisesStream() {                 // NEW
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
      appBar: AppBar(title: const Text("Create Template")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Template name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  const Text("Add exercises:", style: TextStyle(fontSize: 16)),

                  ..._blocks.map((b) => ListTile(
                        title: Text(b.name),
                        subtitle: Text("${b.sets} sets × ${b.reps} reps"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() => _blocks.remove(b));
                          },
                        ),
                      )),
                ],
              ),
            ),

            FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _exercisePicker(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Exercise"),
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: () async {
                final tpl = Template(
                  name: _nameCtrl.text,
                  exercises: _blocks,
                  isCustom: true,
                );

                await TemplateService.addUserTemplate(tpl);

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save Template"),
            ),
          ],
        ),
      ),
    );
  }


// added exercise picker with a search bar and local state
Widget _exercisePicker() {
  final qCtrl = TextEditingController(); //search controller
  String query = '';                      //local query

  return SafeArea(
    child: StatefulBuilder( // local state for the sheet
      builder: (ctx, setLocalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, // use ctx
          ),
          child: SizedBox(
            height: 560,
            child: Column(
              children: [
                // added search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: qCtrl,
                    onChanged: (v) =>
                        setLocalState(() => query = v.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search exercises (name or muscles)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),

                // ist driven by merged stream + search filter
                Expanded(
                  child: StreamBuilder<List<Exercise>>(
                    stream: _allExercisesStream(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final all = [...snap.data!];

                      final filtered = query.isEmpty
                          ? all
                          : all.where((ex) {
                              final n = ex.name.toLowerCase();
                              final m = ex.muscles.toLowerCase();
                              return n.contains(query) || m.contains(query);
                            }).toList()
                            ..sort((a, b) =>
                              a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No matches. Try another search.'),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final ex = filtered[i];
                          return ListTile(
                            title: Row(
                              children: [
                                Text(ex.name),
                                if (ex.isCustom) ...[
                                  const SizedBox(width: 8),
                                  const _CustomTag(),
                                ],
                              ],
                            ),
                            subtitle: Text(ex.muscles),
                            trailing: Text(
                              ex.unit == 'sec'
                                  ? '${ex.reps} sec'
                                  : '${ex.sets}×${ex.reps}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            onTap: () {
                              final muscleList = ex.muscles
                                  .split('•')
                                  .map((m) => m.trim())
                                  .where((m) => m.isNotEmpty)
                                  .toList();

                              setState(() {
                                _blocks.add(
                                  ExerciseBlock(
                                    name: ex.name,
                                    sets: ex.sets,
                                    reps: ex.reps,
                                    muscles: muscleList,
                                  ),
                                );
                              });

                              Navigator.pop(ctx); // use ctx
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
} // closes _exercisePicker()

}

// small custom chip so users can see which ones are their created templates
class _CustomTag extends StatelessWidget {
  const _CustomTag();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text("Custom", style: TextStyle(fontSize: 10)),
    );
  }
}       