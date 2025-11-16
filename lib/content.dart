import 'package:flutter/material.dart';
import 'misc/exercise.dart';
import 'misc/template.dart';
import 'misc/exercise_block.dart';


const List<Exercise> baseExercises = [

  Exercise(name: 'Push-ups', muscles: 'Chest • Triceps • Core', sets: 4, reps: 12),
  Exercise(name: 'Squats', muscles: 'Quads • Glutes • Core', sets: 4, reps: 10),
  Exercise(name: 'Plank', muscles: 'Abs • Lower back', sets: 3, reps: 45, unit: 'sec'),
  Exercise(name: 'Jumping Jacks', muscles: 'Legs • Core', sets: 3, reps: 60, unit: 'sec'),
  Exercise(name: 'Burpees', muscles: 'Chest • Arms • Legs • Core', sets: 4, reps: 12),
  Exercise(name: 'Lunges', muscles: 'Quads • Glutes', sets: 3, reps: 12),
  Exercise(name: 'Mountain Climbers', muscles: 'Core • Shoulders • Arms', sets: 3, reps: 40, unit: 'sec'),
  Exercise(name: 'Bicycle Crunch', muscles: 'Abs • Obliques', sets: 3, reps: 20),
  Exercise(name: 'Russian Twist', muscles: 'Obliques • Core', sets: 3, reps: 30, unit: 'sec'),
  Exercise(name: 'High Knees', muscles: 'Legs • Core', sets: 3, reps: 45, unit: 'sec'),

  Exercise(name: 'Bench Press', muscles: 'Chest • Triceps • Shoulders', sets: 4, reps: 8),
  Exercise(name: 'Incline Dumbbell Press', muscles: 'Chest • Shoulders • Triceps', sets: 4, reps: 10),
  Exercise(name: 'Chest Fly', muscles: 'Chest • Shoulders', sets: 3, reps: 12),

  Exercise(name: 'Pull-ups', muscles: 'Back • Biceps • Shoulders', sets: 4, reps: 8),
  Exercise(name: 'Bent-over Rows', muscles: 'Back • Biceps', sets: 4, reps: 10),
  Exercise(name: 'Lat Pulldown', muscles: 'Back • Arms', sets: 4, reps: 12),

  Exercise(name: 'Shoulder Press', muscles: 'Shoulders • Triceps', sets: 4, reps: 10),
  Exercise(name: 'Lateral Raises', muscles: 'Shoulders', sets: 3, reps: 12),
  Exercise(name: 'Front Raises', muscles: 'Shoulders', sets: 3, reps: 12),

  Exercise(name: 'Bicep Curls', muscles: 'Biceps', sets: 3, reps: 12),
  Exercise(name: 'Tricep Dips', muscles: 'Triceps • Chest', sets: 3, reps: 12),
  Exercise(name: 'Hammer Curls', muscles: 'Biceps • Forearms', sets: 3, reps: 12),

  Exercise(name: 'Deadlift', muscles: 'Hamstrings • Glutes • Lower back', sets: 4, reps: 6),
  Exercise(name: 'Leg Press', muscles: 'Quads • Glutes', sets: 4, reps: 12),
  Exercise(name: 'Calf Raises', muscles: 'Calves', sets: 4, reps: 15),

  Exercise(name: 'Leg Raises', muscles: 'Lower abs', sets: 3, reps: 15),
  Exercise(name: 'Side Plank', muscles: 'Obliques', sets: 3, reps: 30, unit: 'sec'),
  Exercise(name: 'Flutter Kicks', muscles: 'Lower abs • Hip flexors', sets: 3, reps: 40, unit: 'sec'),

  Exercise(name: 'Rowing Machine', muscles: 'Back • Arms • Legs • Core', sets: 3, reps: 300, unit: 'sec'),
  Exercise(name: 'Bike Sprints', muscles: 'Legs • Core', sets: 6, reps: 20, unit: 'sec'),
];

const List<Template> baseTemplates = [
  Template(
    name: 'Push Day (Hypertrophy)',
    exercises: [
      ExerciseBlock(
        name: 'Flat Bench Press',
        sets: 4,
        reps: 8,
        muscles: ['Chest', 'Shoulders', 'Triceps'],
      ),
      ExerciseBlock(
        name: 'Incline DB Press',
        sets: 3,
        reps: 10,
        muscles: ['Chest', 'Shoulders', 'Triceps'],
      ),
      ExerciseBlock(
        name: 'Dip (Assisted)',
        sets: 3,
        reps: 8,
        muscles: ['Chest', 'Triceps', 'Shoulders'],
      ),
      ExerciseBlock(
        name: 'Cable Fly',
        sets: 3,
        reps: 12,
        muscles: ['Chest'],
      ),
      ExerciseBlock(
        name: 'Triceps Rope Pushdown',
        sets: 3,
        reps: 12,
        muscles: ['Triceps'],
      ),
    ],
  ),

  Template(
    name: 'Pull Day (Strength)',
    exercises: [
      ExerciseBlock(
        name: 'Deadlift',
        sets: 5,
        reps: 3,
        muscles: ['Hamstrings', 'Glutes', 'Lower back'],
      ),
      ExerciseBlock(
        name: 'Pull-ups',
        sets: 4,
        reps: 6,
        muscles: ['Back', 'Biceps', 'Shoulders'],
      ),
      ExerciseBlock(
        name: 'Barbell Row',
        sets: 4,
        reps: 5,
        muscles: ['Back', 'Biceps'],
      ),
      ExerciseBlock(
        name: 'Face Pull',
        sets: 3,
        reps: 12,
        muscles: ['Shoulders', 'Upper back', 'Rear delts'],
      ),
    ],
  ),

  Template(
    name: 'Legs + Core',
    exercises: [
      ExerciseBlock(
        name: 'Back Squat',
        sets: 5,
        reps: 5,
        muscles: ['Quads', 'Glutes', 'Core'],
      ),
      ExerciseBlock(
        name: 'Romanian Deadlift',
        sets: 4,
        reps: 8,
        muscles: ['Hamstrings', 'Glutes', 'Lower back'],
      ),
      ExerciseBlock(
        name: 'Leg Press',
        sets: 3,
        reps: 12,
        muscles: ['Quads', 'Glutes'],
      ),
      ExerciseBlock(
        name: 'Hanging Leg Raise',
        sets: 3,
        reps: 12,
        muscles: ['Lower abs', 'Core', 'Hip flexors'],
      ),
    ],
  ),
];



const Map<String, Color> muscleColors = {
  'Chest': Color(0xFFE57373),
  'Back': Color(0xFF64B5F6),
  'Legs': Color(0xFF81C784),
  'Shoulders': Color(0xFFFFB74D),
  'Arms': Color(0xFFBA68C8),
  'Core': Color(0xFFFF8A65),
};

const Map<String, String> muscleToGroup = {
  // Chest
  'Chest': 'Chest',

  // Back
  'Back': 'Back',
  'Lower back': 'Back',
  'Lats': 'Back',

  // Legs
  'Legs': 'Legs',
  'Quads': 'Legs',
  'Hamstrings': 'Legs',
  'Glutes': 'Legs',
  'Calves': 'Legs',

  // Shoulders
  'Shoulders': 'Shoulders',
  'Delts': 'Shoulders',

  // Arms
  'Arms': 'Arms',
  'Biceps': 'Arms',
  'Triceps': 'Arms',
  'Forearms': 'Arms',

  // Core
  'Core': 'Core',
  'Abs': 'Core',
  'Obliques': 'Core',
  'Lower abs': 'Core',
  'Hip flexors': 'Core',
};