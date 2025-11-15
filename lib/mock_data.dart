import 'package:flutter/material.dart';
//import '../template.dart';


// Calories burned over the last 7 days (dummy)
const mockCalories = <int>[420, 580, 610, 500, 730, 660, 710];


// Muscle groups volume (arbitrary units for the week)
const mockMuscleGroups = <String, int>{
  'Chest': 18,
  'Back': 22,
  'Legs': 26,
  'Shoulders': 14,
  'Arms': 16,
  'Core': 20,
};


// Body tracker (e.g., body weight trend over weeks)
const mockBodyWeight = <double>[78.8, 78.6, 78.4, 78.5, 78.2, 78.0, 77.9, 77.7];


// final mockTemplates = <Template>[
//   Template(name: 'Push Day (Hypertrophy)', exercises: [
//     ExerciseBlock(name: 'Flat Bench Press', sets: 4, reps: 8),
//     ExerciseBlock(name: 'Incline DB Press', sets: 3, reps: 10),
//     ExerciseBlock(name: 'Dip (Assisted)', sets: 3, reps: 8),
//     ExerciseBlock(name: 'Cable Fly', sets: 3, reps: 12),
//     ExerciseBlock(name: 'Triceps Rope Pushdown', sets: 3, reps: 12),
//   ]),
//   Template(name: 'Pull Day (Strength)', exercises: [
//     ExerciseBlock(name: 'Deadlift', sets: 5, reps: 3),
//     ExerciseBlock(name: 'Pull-ups', sets: 4, reps: 6),
//     ExerciseBlock(name: 'Barbell Row', sets: 4, reps: 5),
//     ExerciseBlock(name: 'Face Pull', sets: 3, reps: 12),
//   ]),
//   Template(name: 'Legs + Core', exercises: [
//     ExerciseBlock(name: 'Back Squat', sets: 5, reps: 5),
//     ExerciseBlock(name: 'Romanian Deadlift', sets: 4, reps: 8),
//     ExerciseBlock(name: 'Leg Press', sets: 3, reps: 12),
//     ExerciseBlock(name: 'Hanging Leg Raise', sets: 3, reps: 12),
//   ]),
// ];


// Colors for muscle groups (used by calendar and pie chart)
const Map<String, Color> muscleColors = {
  'Chest': Color(0xFFE57373),
  'Back': Color(0xFF64B5F6),
  'Legs': Color(0xFF81C784),
  'Shoulders': Color(0xFFFFB74D),
  'Arms': Color(0xFFBA68C8),
  'Core': Color(0xFFFF8A65),
};


// Dummy per-day muscle work (volume units) for the calendar
// key: DateTime(y,m,d) -> map of muscle group -> volume
final Map<DateTime, Map<String, int>> dayMuscleWork = {
  _d(2025, 10, 10): {'Chest': 12, 'Shoulders': 8, 'Arms': 6},
  _d(2025, 10, 11): {'Back': 16, 'Arms': 10, 'Core': 6},
  _d(2025, 10, 12): {'Legs': 24, 'Core': 8},
  _d(2025, 10, 13): {'Chest': 10, 'Back': 10},
  _d(2025, 10, 14): {'Core': 12},
  _d(2025, 10, 15): {'Shoulders': 14, 'Arms': 8},
  _d(2025, 10, 16): {'Legs': 20},
};


DateTime _d(int y, int m, int d) => DateTime(y, m, d);
class MockExercise {
  final String name;       // e.g., "Push-ups"
  final String category;   // "Cardio" | "Strength" | "Core"
  final String muscles;    // short text like "Chest • Triceps • Core"
  final int sets;          // e.g., 4
  final int count;         // reps or seconds
  final String unit;       // 'reps' or 'sec'

  const MockExercise(
    this.name,
    this.category,
    this.muscles,
    this.sets,
    this.count, {
    this.unit = 'reps',
  });
}

const List<MockExercise> mockExercises = [
  MockExercise('Push-ups', 'Strength', 'Chest • Triceps • Core', 4, 12),
  MockExercise('Squats', 'Strength', 'Quads • Glutes • Core', 4, 10),
  MockExercise('Plank', 'Core', 'Abs • Lower back', 3, 45, unit: 'sec'),
  MockExercise('Jumping Jacks', 'Cardio', 'Full body warm-up', 3, 60, unit: 'sec'),
  MockExercise('Burpees', 'Cardio', 'Full body conditioning', 4, 12),
  MockExercise('Lunges', 'Strength', 'Quads • Glutes • Balance', 3, 12),
  MockExercise('Mountain Climbers', 'Cardio', 'Core • Shoulders', 3, 40, unit: 'sec'),
  MockExercise('Bicycle Crunch', 'Core', 'Abs • Obliques', 3, 20),
  MockExercise('Russian Twist', 'Core', 'Obliques • Core', 3, 30, unit: 'sec'),
  MockExercise('High Knees', 'Cardio', 'Legs • Conditioning', 3, 45, unit: 'sec'),
];