import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_buzz_app/bottomnav.dart';
import 'package:local_buzz_app/screens/otherscreens/username_prompt_screen.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<GeoPoint> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return GeoPoint(position.latitude, position.longitude);
  }
 

  Future<String?> signUpWithEmail({
    required String name,
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create user with email and password
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      // 2. Try to get user location
      GeoPoint? geoPoint;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          geoPoint = GeoPoint(position.latitude, position.longitude);
        }
      } catch (e) {
        geoPoint = null; // If any error or permission denied
      }

      // 3. Save user info in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'nameLower': name.toLowerCase(),
        'username': username,
        'phone': phone,
        'email': email,
        'geo': geoPoint,
        'createdAt': Timestamp.now(),
      });

      return null; // ✅ Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }


  // Future<void> signInWithGoogle(BuildContext context) async {
  //   try {
  //     UserCredential userCredential;

  //     if (kIsWeb) {
  //       // 🔹 Web-specific Google Sign-In
  //       GoogleAuthProvider googleProvider = GoogleAuthProvider();

  //       userCredential = await FirebaseAuth.instance.signInWithPopup(
  //         googleProvider,
  //       );
  //     } else {
  //       // 🔹 Mobile (Android/iOS) Google Sign-In with forced account picker
  //       final googleSignIn = GoogleSignIn(
  //         scopes: ['email'],
  //         forceCodeForRefreshToken:
  //             true, // ✅ Forces account selection each time
  //       );

  //       //await googleSignIn.disconnect(); // Clear previous sessions
  //       await googleSignIn.signOut(); // Force account selection

  //       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //       if (googleUser == null) return;

  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;

  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );

  //       userCredential = await FirebaseAuth.instance.signInWithCredential(
  //         credential,
  //       );
  //     }

  //     final user = userCredential.user;
  //     if (user == null) return;

  //     final userRef = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid);
  //     final userDoc = await userRef.get();

  //     if (!userDoc.exists || !userDoc.data()!.containsKey('username')) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
  //       );
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const BottomNavScreen()),
  //       );
  //     }
  //   } catch (e) {
  //     print("Google Sign-in error: $e");
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Google sign-in failed: $e")));
  //   }
  // }

  Future<void> signInWithGoogle(BuildContext context) async {
  try {
    UserCredential userCredential;

    if (kIsWeb) {
      // 🔹 Web Google Sign-In
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // 🔹 Mobile Google Sign-In (Android/iOS)
      final googleSignIn = GoogleSignIn(scopes: ['email']);

      // Safely sign out any previous session (no disconnect)
      await googleSignIn.signOut();

      // Start the sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // user cancelled login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    }

    // 🔹 Check user in Firestore
    final user = userCredential.user;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    // If new user or missing username → go to username screen
    if (!userDoc.exists || !userDoc.data()!.containsKey('username')) {
      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'geo': null,
        'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    }
  } catch (e) {
    print("Google Sign-in error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google sign-in failed: $e")),
    );
  }
}

  // 🔐 Email Login
  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('[Email Login Success] UID: ${credential.user?.uid}');
      return null;
    } on FirebaseAuthException catch (e) {
      print('[Email Login Error] ${e.message}');
      return e.message;
    } catch (e) {
      print('[Email Login Unknown Error] $e');
      return 'Login failed. Try again.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
