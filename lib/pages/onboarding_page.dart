import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _kcal = TextEditingController();
  final _workouts = TextEditingController();

  File? _image;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_image == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child("$uid.jpg");

    await ref.putFile(_image!);
    return ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (_height.text.isEmpty ||
        _weight.text.isEmpty ||
        _kcal.text.isEmpty ||
        _workouts.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // upload image
    String? imageUrl = await _uploadProfileImage(uid);

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'heightCm': int.tryParse(_height.text) ?? 0,
      'weightKg': double.tryParse(_weight.text) ?? 0.0,
      'kcalTarget': int.tryParse(_kcal.text) ?? 0,
      'workoutsPerWeek': int.tryParse(_workouts.text) ?? 0,
      'profileImageUrl': imageUrl,
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set up your profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _height,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _kcal,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Daily kcal target",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _workouts,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Workouts per week",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
