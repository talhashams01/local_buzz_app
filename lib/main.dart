import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_buzz_app/firebase_options.dart';
import 'package:local_buzz_app/screens/home_feed_screen.dart';
import 'package:local_buzz_app/screens/my_profile_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/fontsize_provider.dart';
import 'package:local_buzz_app/screens/otherscreens/username_prompt_screen.dart';
import 'package:local_buzz_app/screens/public_user_pofile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:local_buzz_app/allSettings/enter_pin_screen.dart';
import 'package:local_buzz_app/bottomnav.dart';
import 'package:local_buzz_app/screens/login_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/bookmarks_provider.dart';
import 'package:local_buzz_app/screens/otherscreens/likes_provider.dart';
import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
import 'package:local_buzz_app/screens/otherscreens/post_provider.dart';
import 'package:local_buzz_app/screens/otherscreens/theme_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedPin = prefs.getString('app_pin');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationSeenProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => LikesProvider()),
        ChangeNotifierProvider(create: (_) => LikeNotifier()),
        ChangeNotifierProvider(create: (_) => MyProfileLikeNotifier()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
      child: MyApp(pinSet: savedPin != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool pinSet;
  const MyApp({super.key, required this.pinSet});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'LocalBuzz',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            useMaterial3: true,
          ),
          home: SplashCheck(pinSet: pinSet),
        );
      },
    );
  }
}

class SplashCheck extends StatelessWidget {
  final bool pinSet;
  const SplashCheck({super.key, required this.pinSet});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) return const LoginScreen();

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, profileSnap) {
            if (!profileSnap.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final data = profileSnap.data?.data() as Map<String, dynamic>?;

            if (data == null || !data.containsKey('username')) {
              return const UsernamePromptScreen();
            }

            return pinSet ? const EnterPinScreen() : const BottomNavScreen();
          },
        );
      },
    );
  }
}