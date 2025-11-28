// app.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW

import 'pages/home_page.dart';
import 'pages/exercises_page.dart';
import 'pages/history_page.dart';
import 'pages/calendar_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/onboarding_page.dart';


class FitApp extends StatelessWidget {
  const FitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack Mockup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 1. Set the home widget to the Auth Checker
      home: const AuthChecker(), 
      routes: {
        // Keep routes for navigation *from* the checker (e.g., after logout)
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const RootShell(),
        '/onboarding': (_) => const OnboardingPage(),
      },
    );
  }
}

// ====================================================================
// NEW: Authentication Checker Widget
// Checks cached token and routes user appropriately
// ====================================================================
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the authentication state stream (handles cached token check)
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // 1. Loading state (Firebase is checking the cached token)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Data state (User is found - either online or via cached token)
        if (snapshot.hasData && snapshot.data != null) {
          // If a User object is returned, they are logged in.
          // Show the main application shell.
          return const RootShell();
        } 
        
        // 3. No data state (No cached token, token expired, or user logged out)
        else {
          // No user found, show the Login page.
          return const LoginPage();
        }
      },
    );
  }
}


// ====================================================================
// RootShell remains the same
// ====================================================================
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 2;

  final _pages = const [
    ExercisesPage(),
    HistoryPage(),
    HomePage(),
    CalendarPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Exercises'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}