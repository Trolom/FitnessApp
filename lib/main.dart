import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'local_db.dart';

import 'misc/workout/workout_service.dart';
import 'misc/user/profile_service.dart';
import 'misc/template/template_service.dart';

import 'misc/workout/workout_bloc.dart';
import 'misc/workout/workout_event.dart';

import 'misc/template/template_bloc.dart';
import 'misc/template/template_event.dart';

import 'misc/user/profile_bloc.dart';
import 'misc/user/profile_event.dart';

import 'misc/exercise/exercise_bloc.dart';
import 'misc/exercise/exercise_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await localDbService.init();
  WorkoutService.monitorAuthState();
  ProfileService.monitorAuthState();
  TemplateService.monitorAuthState();

  runApp(
    ProviderScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutBloc>(
            create: (_) => WorkoutBloc()..add(LoadWorkouts()),
          ),
          BlocProvider<TemplateBloc>(
            create: (_) => TemplateBloc()..add(LoadTemplatesEvent()),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) => ProfileBloc()..add(LoadProfile()),
          ),
          BlocProvider<ExerciseBloc>(
            create: (_) => ExerciseBloc()..add(LoadExercisesEvent()),
          ),
        ],
        child: const FitApp(),
      ),
    ),
  );
}
