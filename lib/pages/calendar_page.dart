import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../charts/day_muscle_pie.dart';
import '../content.dart';
import '../misc/workout/workout_bloc.dart';
import '../misc/workout/workout_state.dart';

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

  List<String> _musclesForDay(DateTime day, Map<DateTime, Map<String, int>> data) {
    final key = DateTime(day.year, day.month, day.day);
    if (!data.containsKey(key)) return const [];

    return data[key]!.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: BlocBuilder<WorkoutBloc, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! WorkoutLoaded) {
            return const Center(child: Text("Load workouts to see the calendar."));
          }

          final dayMuscleWork = state.muscleWorkByDay;
          final selectedKey = _selectedDay == null
              ? null
              : DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: TableCalendar<String>(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  
                  eventLoader: (day) => _musclesForDay(day, dayMuscleWork),

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
                      final muscleGroups = events.cast<String>();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 2,
                          runSpacing: 2,
                          children: muscleGroups.map((group) {
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

              if (selectedKey != null && dayMuscleWork.containsKey(selectedKey))
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
                )
              else if (selectedKey != null)
                const Expanded(
                  child: Center(
                    child: Text("No workout recorded for this day."),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}