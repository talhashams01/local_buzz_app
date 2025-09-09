// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../screens/private_user_profie.dart'; // Update this path if needed

// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const PrivateProfileScreen()),
//               );
//             },
//             child: UserAccountsDrawerHeader(
//               currentAccountPicture: const CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(Icons.person, size: 30, color: Colors.grey),
//               ),
//               accountName: const Text(
//                 "Talha Shams", // Replace later with dynamic name
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               accountEmail: const Text(
//                 "@talhashams", // Replace later with dynamic username
//                 style: TextStyle(fontSize: 14),
//               ),
//               decoration: const BoxDecoration(
//                 color: Colors.blue,
//               ),
//             ),
//           ),

//           ListTile(
//             leading: const Icon(Icons.home),
//             title: const Text("Home"),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.bookmark),
//             title: const Text("Bookmarks"),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.poll),
//             title: const Text("Polls"),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.group),
//             title: const Text("Active Users"),
//             onTap: () {},
//           ),

//           const Spacer(),
//           const Divider(),

//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text(
//               "Logout",
//               style: TextStyle(color: Colors.red),
//             ),
//             onTap: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.popUntil(context, (route) => route.isFirst);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_buzz_app/screens/helpcenter/help_center_screen.dart';
import 'package:local_buzz_app/screens/login_screen.dart';
import 'package:local_buzz_app/screens/my_profile_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/bookmarks_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/saved_location_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/private_user_profie.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Drawer(
      child: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const DrawerHeader(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Name';
              final username = data['username'] ?? 'username';

              return DrawerHeader(
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '@$username',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('reads')
                          .where('uid', isEqualTo: uid)
                          .get(),
                      builder: (context, postSnapshot) {
                        if (!postSnapshot.hasData) return const SizedBox();
                        final count = postSnapshot.data!.docs.length;
                        return Text(
                          'Posts: $count',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: const Text("Account"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivateProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text("Bookmarks"),
            onTap: () {
              // TODO: Navigate to Bookmarks Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarksScreen()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.help_outline),
          //   title: const Text("Help Center"),
          //   onTap: () {
          //     // TODO: Show help dialog or navigate
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text("Saved Locations"),
            onTap: () {
              
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SavedLocationsScreen()));
              
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help Center"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> HelpCenterScreen()));
            },
          ),
           ListTile(
            leading: const Icon(Icons.share),
            title: const Text("Invite a Friend"),
            onTap: () {

              shareApp(context);
              
            },
          ),

          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
              // TODO: Navigate to login screen if needed
            },
          ),
        ],
      ),
    );
  }
}



void shareApp(BuildContext context) {
  const message = '🚀 Check out Local Buzz – a fun social app for local posts!\nDownload now: https://your-app-link.com';
  Share.share(message);
}