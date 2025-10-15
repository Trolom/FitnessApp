import '../template.dart';


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


final mockTemplates = <Template>[
  Template(name: 'Push Day (Hypertrophy)', exercises: [
    ExerciseBlock(name: 'Flat Bench Press', sets: 4, reps: 8),
    ExerciseBlock(name: 'Incline DB Press', sets: 3, reps: 10),
    ExerciseBlock(name: 'Dip (Assisted)', sets: 3, reps: 8),
    ExerciseBlock(name: 'Cable Fly', sets: 3, reps: 12),
    ExerciseBlock(name: 'Triceps Rope Pushdown', sets: 3, reps: 12),
  ]),
  Template(name: 'Pull Day (Strength)', exercises: [
    ExerciseBlock(name: 'Deadlift', sets: 5, reps: 3),
    ExerciseBlock(name: 'Pull-ups', sets: 4, reps: 6),
    ExerciseBlock(name: 'Barbell Row', sets: 4, reps: 5),
    ExerciseBlock(name: 'Face Pull', sets: 3, reps: 12),
  ]),
  Template(name: 'Legs + Core', exercises: [
    ExerciseBlock(name: 'Back Squat', sets: 5, reps: 5),
    ExerciseBlock(name: 'Romanian Deadlift', sets: 4, reps: 8),
    ExerciseBlock(name: 'Leg Press', sets: 3, reps: 12),
    ExerciseBlock(name: 'Hanging Leg Raise', sets: 3, reps: 12),
  ]),
];