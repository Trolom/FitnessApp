import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_profile.dart';
import 'profile_bloc.dart';
import 'profile_event.dart';

/// Opens a dialog to edit basic profile information
Future<void> openEditProfileDialog(
    BuildContext context, UserProfile currentProfile) async {
  final nameCtrl = TextEditingController(text: currentProfile.name);
  final heightCtrl = TextEditingController(text: currentProfile.heightCm.toString());
  final weightCtrl = TextEditingController(text: currentProfile.weightKg.toString());

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty')),
                );
                return;
              }

              final newProfile = currentProfile.copyWith(
                name: name,
                heightCm: int.tryParse(heightCtrl.text.trim()) ?? currentProfile.heightCm,
                weightKg: double.tryParse(weightCtrl.text.trim()) ?? currentProfile.weightKg,
              );

              // Dispatch to BLoC
              context.read<ProfileBloc>().add(UpdateProfileEvent(newProfile));

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

/// Opens a dialog to update the target goal weight
Future<void> editGoalWeightDialog(
  BuildContext context,
  UserProfile currentProfile,
) async {
  final controller = TextEditingController(
    text: currentProfile.goalWeightKg != null ? currentProfile.goalWeightKg!.toString() : '',
  );

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Set goal weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Goal weight (kg)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid number')),
                );
                return;
              }
              
              final newProfile = currentProfile.copyWith(goalWeightKg: value);

              context.read<ProfileBloc>().add(UpdateProfileEvent(newProfile));

              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

/// Logic for daily weight/calorie tracking
Future<void> addDailyEntryDialog(
  BuildContext context,
  double currentWeight,
) async {
  final weightCtrl = TextEditingController(
    text: currentWeight > 0 ? currentWeight.toString() : '',
  );
  final caloriesCtrl = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Track today'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final weightVal = double.tryParse(weightCtrl.text.trim());
              final caloriesVal = int.tryParse(caloriesCtrl.text.trim());

              if (weightVal == null || caloriesVal == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid inputs')),
                );
                return;
              }

              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              final now = DateTime.now();
              final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('dailyLogs')
                    .doc(dateKey)
                    .set({
                  'date': Timestamp.fromDate(now),
                  'weightKg': weightVal,
                  'calories': caloriesVal,
                }, SetOptions(merge: true));

                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

/// Helper to handle user password changes
void changePasswordDialog(BuildContext context) {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPass, obscureText: true, decoration: const InputDecoration(labelText: "Current password")),
            TextField(controller: newPass, obscureText: true, decoration: const InputDecoration(labelText: "New password")),
            TextField(controller: confirmPass, obscureText: true, decoration: const InputDecoration(labelText: "Confirm password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (newPass.text.trim() != confirmPass.text.trim()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords mismatch")));
                return;
              }

              try {
                final cred = EmailAuthProvider.credential(email: user!.email!, password: oldPass.text.trim());
                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newPass.text.trim());
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}

/// Completely removes the user account and data
Future<void> deleteAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final passwordController = TextEditingController();
  final email = user.email!;
  
  final reauth = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Delete Account?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("This action is permanent. Enter password to confirm:"),
          const SizedBox(height: 12),
          TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder())),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text("Delete Forever"),
        )
      ],
    ),
  );

  if (reauth != true) return;

  try {
    final credential = EmailAuthProvider.credential(email: email, password: passwordController.text.trim());
    await user.reauthenticateWithCredential(credential);
    
    final uid = user.uid;
    await FirebaseFirestore.instance.collection("users").doc(uid).delete();
    await user.delete();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}