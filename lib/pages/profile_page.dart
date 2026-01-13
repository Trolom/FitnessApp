import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../misc/user/profile_utils.dart';
import '../misc/user/profile_bloc.dart';
import '../misc/user/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final uid = firebaseUser?.uid;

    if (uid == null) {
      return const Center(child: Text("No user logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final profile = (state is ProfileLoaded) ? state.profile : null;
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: profile != null
                    ? () => openEditProfileDialog(context, profile)
                    : null,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // 1. Handle Loading
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle Error
          if (state is ProfileError) {
            return Center(child: Text("Error loading profile: ${state.message}"));
          }

          // 3. Handle Data
          if (state is ProfileLoaded) {
            final profile = state.profile;
            if (profile == null) {
              return const Center(child: Text("Profile not found"));
            }

            final email = firebaseUser?.email ?? '-';
            final name = profile.name;
            final height = profile.heightCm;
            final weight = profile.weightKg;
            final goalWeight = profile.goalWeightKg;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
                    ),
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

                const SizedBox(height: 24),
                const Text('Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                _Tile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Goal weight',
                  subtitle: goalWeight != null ? '${goalWeight.toStringAsFixed(1)} kg' : 'Tap to set a goal',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => editGoalWeightDialog(context, profile),
                ),

                _Tile(
                  icon: Icons.track_changes,
                  title: 'Track today',
                  subtitle: 'Add weight & calories',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => addDailyEntryDialog(context, weight),
                ),

                const SizedBox(height: 16),
                const Divider(),

                const SizedBox(height: 12),
                const Text('Account & Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                _Tile(
                  icon: Icons.lock_outline,
                  title: 'Change password',
                  subtitle: 'Manage your sign-in',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => changePasswordDialog(context),
                ),
                
                _Tile(
                  icon: Icons.delete_forever,
                  title: 'Delete account',
                  subtitle: 'Remove account and all data',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => deleteAccount(context),
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
          }

          return const SizedBox.shrink();
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