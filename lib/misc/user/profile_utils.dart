import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_profile.dart';
import 'profile_providers.dart';

Future<void> openEditProfileDialog(
    BuildContext context, WidgetRef ref, UserProfile currentProfile) async {
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty')),
                );
                return;
              }

              final height = int.tryParse(heightCtrl.text.trim()) ?? currentProfile.heightCm;
              final weight = double.tryParse(weightCtrl.text.trim()) ?? currentProfile.weightKg;
              
              final newProfile = currentProfile.copyWith(
                name: name,
                heightCm: height,
                weightKg: weight,
              );

              try {
                await ref.read(profileControllerProvider).updateProfile(newProfile);

                if (context.mounted) Navigator.pop(ctx);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated (Syncing...)')),
                );
              } on Exception catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update profile: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> editGoalWeightDialog(
  BuildContext context,
  WidgetRef ref,
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
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Goal weight (kg)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(controller.text.trim());
              if (value == null) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid number for goal weight')),
                );
                return;
              }
              
              final newProfile = currentProfile.copyWith(
                goalWeightKg: value,
              );

              try {
                await ref.read(profileControllerProvider).updateProfile(newProfile);

                if (context.mounted) Navigator.pop(ctx);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal weight updated (Syncing...)')),
                );
              } on Exception catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update goal weight: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


// daily entry dialog
Future<void> addDailyEntryDialog(
  BuildContext context,
  WidgetRef ref,
  double currentWeight,
) async {
  // it currently still uses direct Firebase calls as the DailyLog
  // model and providers not implemented yet

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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories (kcal)',
                ),
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
            onPressed: () async {
              final weightVal = double.tryParse(weightCtrl.text.trim());
              final caloriesVal = int.tryParse(caloriesCtrl.text.trim());

              if (weightVal == null || caloriesVal == null) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid weight and calories')),
                );
                return;
              }

              final uid = FirebaseAuth.instance.currentUser!.uid;
              final now = DateTime.now();
              final dateKey =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

              try {
                // should be replaced by DailyLogNotifier.add(log) later 
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
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry saved')),
                );
              } on FirebaseException catch (e) {
                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message ?? 'Failed to save entry')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void changePasswordDialog(BuildContext context) {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPass, obscureText: true, decoration: const InputDecoration(labelText: "Current password")),
            const SizedBox(height: 12),
            TextField(controller: newPass, obscureText: true, decoration: const InputDecoration(labelText: "New password")),
            const SizedBox(height: 12),
            TextField(controller: confirmPass, obscureText: true, decoration: const InputDecoration(labelText: "Confirm new password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (newPass.text.trim() != confirmPass.text.trim()) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New passwords do not match")),
                );
                return;
              }

              try {
                final cred = EmailAuthProvider.credential(email: user!.email!, password: oldPass.text.trim());
                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newPass.text.trim());

                if (context.mounted) Navigator.pop(context);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated successfully")),
                );
              } on FirebaseAuthException catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message ?? "Error updating password")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}


Future<void> deleteAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final passwordController = TextEditingController();
  final email = user.email!;
  final reauth = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Confirm identity"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Enter your password to delete your account ($email)"),
          const SizedBox(height: 12),
          TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text("Confirm"),
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
  } on FirebaseAuthException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "Failed to delete account")),
    );
  }
}