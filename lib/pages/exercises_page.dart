import 'package:flutter/material.dart';
import '../mock_data.dart';

// to create like a design plan for this page
// we specify here that our page is going to be statefull
class ExercisesPage extends StatefulWidget {
  //this line is for saying that key could be passed if needed
  // if we have 2 identical exercises page, this will be needed
  const ExercisesPage({super.key});

  //we tell to create a helper object that will tell to manage
  // the changable states in a seperate object
  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  // a controller to read/listen to the text from the search bar
  final _searchCtrl = TextEditingController();

  final List<String> _categories = const ['All', 'Cardio', 'Strength', 'Core'];
  String _selectedCat = 'All';


  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockExercise> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return mockExercises.where((e) {
      final matchesCat = _selectedCat == 'All' || e.category == _selectedCat;
      final matchesQuery = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.muscles.toLowerCase().contains(q);
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search exercises (e.g. push, core)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCat = cat),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ExerciseTile(ex: _filtered[i]),
                  ),
          ),
        ],
      ),

      // Mocked action for M1
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final MockExercise ex;
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
          child: Text(ex.name.isNotEmpty ? ex.name.substring(0, 1) : '?'),
        ),
        title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${ex.category} • ${ex.muscles}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ex.unit == 'sec' ? '${ex.count} ${ex.unit}' : '${ex.sets}×${ex.count}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(ex.unit == 'sec' ? 'Hold' : 'Sets×Reps', style: const TextStyle(fontSize: 12)),
          ],
        ),
        onTap: () {
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
                  Text(ex.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('${ex.category} • ${ex.muscles}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Pill(text: ex.unit == 'sec' ? '${ex.count} ${ex.unit}' : '${ex.sets}×${ex.count}'),
                      const SizedBox(width: 8),
                      const _Pill(text: 'Bodyweight'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How to:\nKeep core tight, control movement, and breathe steadily.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${ex.name}')),
                      );
                    },
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add to today'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(text),
    );
  }
}

class _EmptyState extends StatelessWidget {
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
            Text('No exercises match your filters.'),
          ],
        ),
      ),
    );
  }
}