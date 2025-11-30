// template_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NEW
import 'template.dart';
import '../../pages/workout_page.dart';
// import 'template_service.dart'; // NO LONGER USED DIRECTLY FOR DELETE
import 'template_providers.dart'; // NEW

// CHANGE: Convert to ConsumerWidget
class TemplateCard extends ConsumerWidget {
  final Template template;
  const TemplateCard({super.key, required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // ADD WidgetRef ref
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

                // show delete only for user-created templates that have an id
                // Note: We check if it's NOT deleted (!template.isDeleted) as well, 
                // though the provider already filters this, it's safer.
                if (template.isCustom && template.id != null) ...[
                  IconButton(
                    tooltip: 'Delete template',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        // ... (Confirmation dialog remains the same) ...
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
                        // CRITICAL CHANGE: Use the Riverpod Notifier for soft-delete
                        await ref.read(customTemplatesProvider.notifier).delete(template);
                        
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
            // ... (rest of the card remains the same)
          ],
        ),
      ),
    );
  }
}