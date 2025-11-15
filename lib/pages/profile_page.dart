import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("No user logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          // Firestore fields
          final name = data['name'] ?? 'User';
          final height = data['heightCm'] ?? 0;
          final weight = data['weightKg'] ?? 0.0;
          final kcalTarget = data['kcalTarget'] ?? 0;
          final workoutsPerWeek = data['workoutsPerWeek'] ?? 0;
          final imageUrl = data['profileImageUrl'];

          final email = FirebaseAuth.instance.currentUser?.email ?? '-';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Avatar + name + email
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null
                        ? const Icon(Icons.person, size: 36)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            )),
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

              const SizedBox(height: 12),
              const Text('Goals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              _Tile(
                icon: Icons.flag,
                title: 'Weekly workouts',
                subtitle: "$workoutsPerWeek / week",
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              _Tile(
                icon: Icons.flag,
                title: 'Kcal/day',
                subtitle: "$kcalTarget",
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
                  _changePasswordDialog(context);
                },
              ),
              _Tile(
                icon: Icons.delete_forever,
                title: 'Delete account',
                subtitle: 'Remove account and all data',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _deleteAccount(context);
                },
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (_) => false);
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

Future<void> _deleteAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Ask user to confirm password before deleting account
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
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
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
    // 1. Reauthenticate
    final credential = EmailAuthProvider.credential(
      email: email,
      password: passwordController.text.trim(),
    );

    await user.reauthenticateWithCredential(credential);

    final uid = user.uid;

    // 2. Delete Firestore doc
    await FirebaseFirestore.instance.collection("users").doc(uid).delete();

    // 3. Delete Firebase Auth account
    await user.delete();

    // 4. Navigate to login
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "Failed to delete account")),
    );
  }
}

void _changePasswordDialog(BuildContext context) {
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
            TextField(
              controller: oldPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current password",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New password",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm new password",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              if (newPass.text.trim() != confirmPass.text.trim()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New passwords do not match")),
                );
                return;
              }

              try {
                // re-authenticate user
                final cred = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: oldPass.text.trim(),
                );

                await user.reauthenticateWithCredential(cred);

                // change password
                await user.updatePassword(newPass.text.trim());

                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated successfully")),
                );
                
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
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
