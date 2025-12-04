import 'package:flutter/material.dart';
import 'workout/workout_log.dart';

class HistoryCard extends StatelessWidget {
  final WorkoutLog w;
  const HistoryCard({super.key, required this.w});

  String _fmtDateTime(DateTime d) {
    const weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year} '
        'at ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  w.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              _buildSyncStatus(context),
            ],
          ),
          
          const SizedBox(height: 2),

          Text(
            _fmtDateTime(w.when),
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _LabeledBlock(label: 'Sets', child: Text(w.setsDesc)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledBlock(label: 'Best set', alignRight: true, child: Text(w.bestSet)),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 6),
              Text('${(w.durationSec / 60).round()}m'),
              const SizedBox(width: 16),
              const Icon(Icons.fitness_center, size: 18),
              const SizedBox(width: 6),
              Text('${_compactNumber(w.totalKg)} kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(BuildContext context) {
    if (w.syncStatus == 'pending') {
      // offline or Waiting to upload
      return const Tooltip(
        message: 'Saved locally. Waiting for internet...',
        child: Icon(Icons.cloud_upload_outlined, color: Colors.orange, size: 20),
      );
    } else if (w.syncStatus == 'synced') {
      // uccessfully uploaded
      return Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary, size: 20);
    } else {
      // error state
      return const Icon(Icons.error_outline, color: Colors.red, size: 20);
    }
  }

  String _compactNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}


class _LabeledBlock extends StatelessWidget {
  final String label;
  final Widget child;
  final bool alignRight;
  const _LabeledBlock({required this.label, required this.child, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).textTheme.bodySmall?.color;
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: hint)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}