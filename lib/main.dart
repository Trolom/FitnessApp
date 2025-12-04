import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'local_db.dart';
import 'misc/workout/workout_service.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await localDbService.init(); 
    WorkoutService.syncPendingWorkouts();
    
    runApp(
      const ProviderScope(
        child: FitApp(),
      ),
    );
}