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
// error on templates
// edit button on profile
// button to delete template

// E/flutter (30189): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Bad state: No element
// E/flutter (30189): #0      Iterable.lastWhere (dart:core/iterable.dart:753:9)
// iterable.dart:753
// E/flutter (30189): #1      NavigatorState.pop (package:flutter/src/widgets/navigator.dart:5574:40)
// navigator.dart:5574
// E/flutter (30189): #2      Navigator.pop (package:flutter/src/widgets/navigator.dart:2774:27)
// navigator.dart:2774
// E/flutter (30189): #3      _CreateTemplatePageState.build.<anonymous closure> (package:fitness_app_mock/pages/create_template_page.dart:80:48)
// create_template_page.dart:80
// E/flutter (30189): <asynchronous suspension>
// E/flutter (30189): 
// I/ImeTracker(30189): system_server:f6ea9fdd: onCancelled at PHASE_CLIENT_ON_CONTROLS_CHANGED
// D/VRI[MainActivity](30189): visibilityChanged oldVisibility=true newVisibility=false
// I/AutofillManager(30189): onInvisibleForAutofill(): expiringResponse
// V/NativeCrypto(30189): Read error: ssl=0x773deb430458: I/O error during system call, Software caused connection abort
// V/NativeCrypto(30189): Write error: ssl=0x773deb430458: I/O error during system call, Broken pipe
// W/Firestore(30189): (26.0.2) [WatchStream]: (244f4cf) Stream closed with status: Status{code=UNAVAILABLE, description=End of stream or IOException, cause=null}.
// W/Firestore(30189): (26.0.2) [WriteStream]: (3f18b42) Stream closed with status: Status{code=UNAVAILABLE, description=End of stream or IOException, cause=null}.