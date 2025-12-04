import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'template.dart';
import '../../pages/workout_page.dart';
import 'template_providers.dart'; 

class TemplateCard extends ConsumerWidget {
  final Template template;
  const TemplateCard({super.key, required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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

                // Show delete only for usercreated templates
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
                        // used controller to delete
                        await ref.read(templateControllerProvider).delete(template.id!);
                        
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
            ...template.exercises.take(3).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "• ${e.name} (${e.sets} × ${e.reps})",
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            )),
            if (template.exercises.length > 3)
              Text("... and ${template.exercises.length - 3} more", 
                   style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}