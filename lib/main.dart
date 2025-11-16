import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';


Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const FitApp());
}


// Remove add to today button when pressing an exercise
// make custom exercise be available in templates
// make muscle type be a drop down with specific options
// solve graphs