import 'package:flutter/material.dart';
import '../misc/template.dart';
import '../misc/template_service.dart';
import '../content.dart';
import '../misc/exercise_block.dart';

class CreateTemplatePage extends StatefulWidget {
  const CreateTemplatePage({super.key});

  @override
  State<CreateTemplatePage> createState() => _CreateTemplatePageState();
}

class _CreateTemplatePageState extends State<CreateTemplatePage> {
  final _nameCtrl = TextEditingController();
  final List<ExerciseBlock> _blocks = [];

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

  Widget _exercisePicker() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: baseExercises.map((ex) {
        return ListTile(
          title: Text(ex.name),
          subtitle: Text(ex.muscles),
          onTap: () {
            // Convert "Chest • Triceps • Core" → ['Chest','Triceps','Core']
            final muscleList = ex.muscles
                .split(' • ')
                .map((m) => m.trim())
                .where((m) => m.isNotEmpty)
                .toList();

            setState(() {
              _blocks.add(
                ExerciseBlock(
                  name: ex.name,
                  sets: ex.sets,
                  reps: ex.reps,
                  muscles: muscleList,   // ← NEW
                ),
              );
            });

            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }
}
