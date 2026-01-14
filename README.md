# FitTrack: Offline-Capable Fitness Logger

## Team Composition

| Name   | Surname  | Group          |
|--------|----------|----------------|
| Yslam  | Hemrayev | 1241EC |
| Dragos | Rascanu  | 1241EC |

## Project Description

FitTrack is a Flutter mobile application designed for high-reliability fitness tracking in low-connectivity environments. Using an Offline-First architecture, it ensures a zero-latency user experience by prioritizing local data persistence.

## Key Functionality

* **Local-First Sync**: Logs workouts instantly to a local Hive database and synchronizes with Firebase Firestore once a connection is available.
* **Data Integrity**: Implements "Last-Write-Wins" conflict resolution and soft-deletion logic to keep data consistent across devices.
* **Performance**: Uses BLoC state management and reactive streams to update analytics without blocking the UI or draining battery.

## Implemented Screens

* **Auth Gate**: Secure Firebase login and registration flow.
* **Dashboard**: Real-time analytics with muscle group distribution charts.
* **Workout Logger**: Interface for recording exercises, sets, and reps with sync status indicators.
* **Template Manager**: Tools to create, save, and manage reusable workout routines.
* **History & Calendar**: Visual log of past workouts and monthly consistency markers.
* **Profile**: Personal health metrics and cloud-stored profile imagery.

## Technology Stack

* Flutter (Material 3)
* State management: BLoC
* Local storage: Hive
* Cloud: Firebase Firestore + Firebase Storage
* Visualization: fl_chart, table_calendar