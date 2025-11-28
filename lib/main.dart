import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NEW
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'local_db.dart'; // NEW: For Hive initialization

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Initialize Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // 2. Initialize Hive local DB (must run before Riverpod tries to read data)
    await localDbService.init(); 
    
    // 3. Wrap app in ProviderScope for Riverpod
    runApp(
      const ProviderScope(
        child: FitApp(),
      ),
    );
}