import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:local_buzz_app/screens/login_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/username_prompt_screen.dart';
//import 'package:local_buzz_app/username_prompt_screen.dart';
import 'package:local_buzz_app/bottomnav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!doc.exists || !doc.data()!.containsKey('username')) {
        // User is signed in but has no profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
        );
      } else {
        // Signed in and profile exists
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavScreen()),
        );
      }
    } else {
      // Not signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}