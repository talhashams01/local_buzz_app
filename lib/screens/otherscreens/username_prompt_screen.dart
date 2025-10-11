


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_buzz_app/bottomnav.dart';

class UsernamePromptScreen extends StatefulWidget {
  const UsernamePromptScreen({super.key});

  @override
  State<UsernamePromptScreen> createState() => _UsernamePromptScreenState();
}

class _UsernamePromptScreenState extends State<UsernamePromptScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool isSaving = false;

  Future<void> saveUsername() async {
    final String username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => isSaving = true);

    try {
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username is already taken.")),
        );
        setState(() => isSaving = false);
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'name': user.displayName ?? '',
          'nameLower': (user.displayName ?? '').toLowerCase(),
          'email': user.email,
          'uid': user.uid,
          'geo': await _getUserLocation(),
        }, SetOptions(merge: true));

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username saved successfully.")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save username: $e")),
      );
    }

    setState(() => isSaving = false);
  }

  Future<GeoPoint?> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Choose a Username")),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Enter Username",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving ? null : saveUsername,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save & Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}