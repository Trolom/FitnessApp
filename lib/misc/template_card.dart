import 'package:flutter/material.dart';
import 'template.dart';
import '../../pages/workout_page.dart';
import 'template_service.dart';

class TemplateCard extends StatelessWidget {
  final Template template;
  const TemplateCard({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16), // FIX: named param
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),

                // show delete only for user-created templates that have an id
                if (template.isCustom && template.id != null) ...[
                  IconButton(
                    tooltip: 'Delete template',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete template?'),
                          content: Text('Are you sure you want to delete "${template.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (ok == true) {
                        await TemplateService.deleteUserTemplate(template.id!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Template deleted')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                ],

                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WorkoutPage(template: template),
                      ),
                    );
                  },
                  child: const Text('Use'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: template.exercises
                  .take(4)
                  .map((e) => Chip(label: Text('${e.name} • ${e.sets}x${e.reps}')))
                  .toList(),
            ),

            if (template.exercises.length > 4) ...[
              const SizedBox(height: 8),
              Text(
                '+${template.exercises.length - 4} more',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
