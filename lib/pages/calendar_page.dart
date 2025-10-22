import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../mock_data.dart';
import '../charts/day_muscle_pie.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  List<String> _musclesForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final map = dayMuscleWork[key];
    if (map == null) return const [];
    return map.entries.where((e) => e.value > 0).map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = _selectedDay == null
        ? null
        : DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TableCalendar<String>(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: (day) => _musclesForDay(day),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  final groups = events.cast<String>();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2,
                      runSpacing: 2,
                      children: groups.map((group) {
                        final color = muscleColors[group] ?? Colors.grey;
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
          if (selectedKey != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DayMusclePie(
                      data: dayMuscleWork[selectedKey] ?? const {},
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
