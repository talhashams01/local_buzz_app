



import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_buzz_app/bottomnav.dart';
import 'package:local_buzz_app/screens/otherscreens/username_prompt_screen.dart';

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

// 🔐 Google Sign-in

// Future<User?> signInWithGoogle(BuildContext context) async {
//   try {
//     await GoogleSignIn().signOut(); // Force sign-out before sign-in
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return;

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//     final user = userCredential.user;

//     if (user != null) {
//       final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//       final userDoc = await userRef.get();

//       String? username;
//       if (!userDoc.exists || !userDoc.data()!.containsKey('username')) {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
//         );

//         if (result == null || result is! String || result.trim().isEmpty) {
//           await FirebaseAuth.instance.signOut();
//           return;
//         }

//         username = result.trim();
//       } else {
//         username = userDoc.data()!['username'];
//       }

//       GeoPoint? geoPoint;
//       try {
//         LocationPermission permission = await Geolocator.checkPermission();
//         if (permission == LocationPermission.denied) {
//           permission = await Geolocator.requestPermission();
//         }

//         if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
//           final position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high,
//           );
//           geoPoint = GeoPoint(position.latitude, position.longitude);
//         }
//       } catch (e) {
//         geoPoint = null;
//       }

//       // Save or update user data
//       await userRef.set({
//         'uid': user.uid,
//         'name': user.displayName ?? '',
//         'nameLower': (user.displayName ?? '').toLowerCase(),
//         'username': username,
//         'email': user.email ?? '',
//         'geo': geoPoint,
//         'createdAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       // ✅ Navigate to BottomNavScreen directly
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const BottomNavScreen()));
//     }
//   } catch (e) {
//     print("Google Sign-in error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Google sign-in failed")),
//     );
//   }
// }

// Future<void> signInWithGoogle(BuildContext context) async {
//   try {
//     await GoogleSignIn().signOut(); // Force account selection

//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return;

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//     final user = userCredential.user;

//     if (user != null) {
//       final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//       final userDoc = await userRef.get();

//       String? username;
//       if (!userDoc.exists || !userDoc.data()!.containsKey('username')) {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
//         );

//         if (result == null || result is! String || result.trim().isEmpty) {
//           await FirebaseAuth.instance.signOut(); // Cancel login
//           return;
//         }

//         username = result.trim();

//         // Location
//         GeoPoint? geoPoint;
//         try {
//           final position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high,
//           );
//           geoPoint = GeoPoint(position.latitude, position.longitude);
//         } catch (e) {
//           geoPoint = null;
//         }

//         await userRef.set({
//           'uid': user.uid,
//           'name': user.displayName ?? '',
//           'nameLower': (user.displayName ?? '').toLowerCase(),
//           'username': username,
//           'email': user.email ?? '',
//           'geo': geoPoint,
//           'createdAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       }

//       // ✅ Navigate to BottomNavScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const BottomNavScreen()),
//       );
//     }
//   } catch (e) {
//     print("Google Sign-in error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Google sign-in failed")),
//     );
//   }
// }


// Future<void> signInWithGoogle(BuildContext context) async {
//   try {
//     await GoogleSignIn().signOut(); // Force fresh login
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return;

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential =
//         await FirebaseAuth.instance.signInWithCredential(credential);
//     final user = userCredential.user;

//     if (user != null) {
//       final userRef =
//           FirebaseFirestore.instance.collection('users').doc(user.uid);
//       final userDoc = await userRef.get();

//       if (!userDoc.exists || !userDoc.data()!.containsKey('username')) {
//         // No username set — navigate to UsernamePromptScreen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
//         );
//         return; // Don't proceed
//       }

//       // ✅ If username exists, navigate to Home
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const BottomNavScreen()),
//       );
//     }
//   } catch (e) {
//     print("Google Sign-in error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Google sign-in failed")),
//     );
//   }
// }




// Future<void> signInWithGoogle(BuildContext context) async {
//   try {
//     final googleSignIn = GoogleSignIn(
//       scopes: ['email'],
//       // This ensures fresh auth and avoids silent login
//       signInOption: SignInOption.standard,
//       forceCodeForRefreshToken: true,
//     );

//     await googleSignIn.signOut(); // ✅ Important: clears session

//     final GoogleSignInAccount? googleUser = await googleSignIn.signIn(); // ✅ Shows picker
//     if (googleUser == null) return;

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential =
//         await FirebaseAuth.instance.signInWithCredential(credential);
//     final user = userCredential.user;

//     if (user != null) {
//       final userRef =
//           FirebaseFirestore.instance.collection('users').doc(user.uid);
//       final userDoc = await userRef.get();

//       if (!userDoc.exists || !userDoc.data()!.containsKey('username')) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
//         );
//         return;
//       }

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const BottomNavScreen()),
//       );
//     }
//   } catch (e) {
//     print("Google Sign-in error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Google sign-in failed")),
//     );
//   }
// }



// Future<void> signInWithGoogle(BuildContext context) async {
//   try {
//     await GoogleSignIn().signOut(); // Always fresh login
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return;

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//     final user = userCredential.user;

//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User not found")),
//       );
//       return;
//     }

//     final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//     final userDoc = await userRef.get();

//     if (!userDoc.exists || !(userDoc.data()?.containsKey('username') ?? false)) {
//       // ⚠ No profile — move to username screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
//       );
//       return;
//     }

//     // ✅ User and profile exists
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const BottomNavScreen()),
//     );
//   } catch (e) {
//     print("Google Sign-in error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Google sign-in failed")),
//     );
//   }
// }




Future<void> signInWithGoogle(BuildContext context) async {
  try {
    await GoogleSignIn().signOut(); // Force account selection
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists || !userDoc.data()!.containsKey('username')) {
      // ❗ Profile incomplete, go to username screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UsernamePromptScreen()),
      );
    } else {
      // ✅ Profile exists, go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    }
  } catch (e) {
    print("Google Sign-in error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google sign-in failed")),
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