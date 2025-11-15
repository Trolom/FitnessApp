import 'package:flutter/material.dart';
import 'template.dart';
import '../../pages/workout_page.dart';


class TemplateCard extends StatelessWidget {
  final Template template;
  const TemplateCard({super.key, required this.template});


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(template.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
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
              children: template.exercises.take(4).map((e) => Chip(label: Text('${e.name} • ${e.sets}x${e.reps}'))).toList(),
            ),
            if (template.exercises.length > 4) ...[
              const SizedBox(height: 8),
              Text('+${template.exercises.length - 4} more', style: Theme.of(context).textTheme.bodySmall)
            ]
          ],
        ),
      ),
    );
  }
}