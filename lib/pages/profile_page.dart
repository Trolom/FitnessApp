import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'No email';

    // Temporary dummy values — later you can store/retrieve from Firestore
    const heightCm = 178;
    const weightKg = 78.2;
    const weeklyGoal = '4 workouts / week';
    const kcalTarget = 2400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: open edit profile page
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Avatar + name + email
          Row(
            children: [
              const CircleAvatar(
                radius: 34,
                child: Icon(Icons.person, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          const SizedBox(height: 12),
          Row(
            children: const [
              _StatCard(label: 'Height', value: '$heightCm cm'),
              SizedBox(width: 12),
              _StatCard(label: 'Weight', value: '$weightKg kg'),
              SizedBox(width: 12),
              _StatCard(label: 'Target kcal', value: '$kcalTarget'),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          const SizedBox(height: 12),
          const Text('Goals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.flag,
            title: 'Weekly workouts',
            subtitle: weeklyGoal,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _Tile(
            icon: Icons.local_fire_department,
            title: 'Daily calories',
            subtitle: '$kcalTarget kcal',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 16),
          const Divider(),

          const SizedBox(height: 12),
          const Text('Account & Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          _Tile(
            icon: Icons.lock_outline,
            title: 'Change password',
            subtitle: 'Manage your sign-in',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: implement change password
            },
          ),
          _Tile(
            icon: Icons.delete_forever,
            title: 'Delete account',
            subtitle: 'Remove account and all data',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: implement account deletion
            },
          ),

          const SizedBox(height: 24),

          // LOGOUT BUTTON
          FilledButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
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
