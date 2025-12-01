import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../misc/user/profile_providers.dart';
import '../misc/user/profile_utils.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final uid = firebaseUser?.uid;

    if (uid == null) {
      return const Center(child: Text("No user logged in"));
    }

    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: profileAsync.isLoading
                ? null
                : () {
                    if (profileAsync.hasValue) {
                      openEditProfileDialog(context, ref, profileAsync.value!);
                    }
                  },
          ),
        ],
      ),

      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading profile.")),
        data: (profile) {
          final email = firebaseUser?.email ?? '-';
          final name = profile.name;
          final height = profile.heightCm;
          final weight = profile.weightKg;
          final goalWeight = profile.goalWeightKg;
          final imageUrl = profile.profileImageUrl;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Avatar + name + email
              Row(
                children: [
                  CircleAvatar( /* ... avatar logic ... */ ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),

              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(label: 'Height', value: '$height cm'),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Weight', value: '$weight kg'),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Divider(),

              const SizedBox(height: 12),
              const Text('Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              // Goal Weight Tile
              _Tile(
                icon: Icons.monitor_weight_outlined,
                title: 'Goal weight',
                subtitle: goalWeight != null ? '${goalWeight.toStringAsFixed(1)} kg' : 'Tap to set a goal',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Call utility function
                  editGoalWeightDialog(context, ref, profile);
                },
              ),

              // Track Today Tile
              _Tile(
                icon: Icons.track_changes,
                title: 'Track today',
                subtitle: 'Add weight & calories',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Call utility function
                  addDailyEntryDialog(context, ref, weight);
                },
              ),

              const SizedBox(height: 16),
              const Divider(),

              const SizedBox(height: 12),
              const Text('Account & Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              // Change Password Tile
              _Tile(
                icon: Icons.lock_outline,
                title: 'Change password',
                subtitle: 'Manage your sign-in',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Call utility function
                  changePasswordDialog(context);
                },
              ),
              
              // Delete Account Tile
              _Tile(
                icon: Icons.delete_forever,
                title: 'Delete account',
                subtitle: 'Remove account and all data',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Call utility function
                  deleteAccount(context);
                },
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          );
        },
      ),
    );
  }
}



class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}