class Template {
  final String name;
  final List<ExerciseBlock> exercises;


  Template({required this.name, required this.exercises});
}


class ExerciseBlock {
  final String name;
  final int sets;
  final int reps;


  ExerciseBlock({required this.name, required this.sets, required this.reps});
}
