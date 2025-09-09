// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';
// //import 'package:local_buzz_app/screens/home_screen.dart';
// import 'package:local_buzz_app/screens/post_read_screen.dart';
// import 'package:local_buzz_app/screens/search_screen.dart';
// // import 'package:local_buzz_app/screens/post_read_screen.dart';
// // import 'package:local_buzz_app/screens/search_screen.dart';
// // import 'package:local_buzz_app/screens/notifications_screen.dart';
// // import 'package:local_buzz_app/screens/profile_screen.dart';

// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({super.key});

//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [

//     const HomeFeedScreen(),
//     const CreateReadScreen(), // Assuming feedsScreen is defined in post_read_screen.dart
//     const SearchScreen(),
//     //const NotificationsScreen(),
//     //const ProfileScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         currentIndex: _selectedIndex,
//         selectedItemColor: isDark ? Colors.white : Colors.black,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home Feed", tooltip: "Home Feed"),
//           BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: "Post", tooltip: "Create Post"),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search",tooltip: "Search"),
//           // BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Notifications"),
//           // BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/Notification_screen.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';
// import 'package:local_buzz_app/screens/my_profile_screen.dart';
// //import 'package:local_buzz_app/screens/otherscreens/poll_creation_screen.dart';
// import 'package:local_buzz_app/screens/post_read_screen.dart';
// //import 'package:local_buzz_app/screens/public_user_pofile.dart';
// import 'package:local_buzz_app/screens/search_screen.dart';

// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({super.key});

//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _selectedIndex = 0;

//   final currentUserId = FirebaseAuth
//       .instance
//       .currentUser!
//       .uid; // Assuming userId is defined somewhere

//   final List<Widget> _screens = [
//     const HomeFeedScreen(key: PageStorageKey('HomeFeed')),
//     const CreateReadScreen(key: PageStorageKey('CreateRead')),
//     const SearchScreen(key: PageStorageKey('Search')),
//     NotificationsTab(key: PageStorageKey('Notifications')),
//     MyProfileScreen(
//       key: PageStorageKey('Profile'),
//     ), // Assuming userId is defined somewhere
//   ];

//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         currentIndex: _selectedIndex,
//         selectedItemColor: isDark ? Colors.white : Colors.black,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: "Home Feed",
//             tooltip: "Home Feed",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.add_box_outlined),
//             label: "Post",
//             tooltip: "Create Post",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: "Search",
//             tooltip: "Search",
//           ),
//           BottomNavigationBarItem(
//             icon: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(currentUserId)
//                   .collection('notifications')
//                   .where('seen', isEqualTo: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 final hasUnread =
//                     snapshot.hasData && snapshot.data!.docs.isNotEmpty;

//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.notifications),
//                     if (hasUnread)
//                       Positioned(
//                         right: -2,
//                         top: -2,
//                         child: Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//             label: "Notifications",
//             tooltip: "Notifications",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline_outlined),
//             label: "Profile",
//             tooltip: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/Notification_screen.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';
// import 'package:local_buzz_app/screens/my_profile_screen.dart';
// import 'package:local_buzz_app/screens/post_read_screen.dart';
// import 'package:local_buzz_app/screens/search_screen.dart';

// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({super.key});

//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _selectedIndex = 0;
//   bool hasUnreadNotifications = false;

//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   final List<Widget> _screens = [
//     const HomeFeedScreen(key: PageStorageKey('HomeFeed')),
//     const CreateReadScreen(key: PageStorageKey('CreateRead')),
//     const SearchScreen(key: PageStorageKey('Search')),
//     NotificationsTab(key: PageStorageKey('Notifications')),
//     MyProfileScreen(key: PageStorageKey('Profile')),
//   ];

//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         currentIndex: _selectedIndex,
//         selectedItemColor: isDark ? Colors.white : Colors.black,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: "Home Feed",
//             tooltip: "Home Feed",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.add_box_outlined),
//             label: "Post",
//             tooltip: "Create Post",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: "Search",
//             tooltip: "Search",
//           ),
//           BottomNavigationBarItem(
//             icon: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(currentUserId)
//                   .collection('notifications')
//                   .where('seen', isEqualTo: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 final hasUnread =
//                     snapshot.hasData && snapshot.data!.docs.isNotEmpty;

//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.notifications),
//                     if (hasUnread)
//                       Positioned(
//                         right: -2,
//                         top: -2,
//                         child: Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//             label: "Notifications",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline_outlined),
//             label: "Profile",
//             tooltip: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/Notification_screen.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';
// import 'package:local_buzz_app/screens/my_profile_screen.dart';
// import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
// import 'package:local_buzz_app/screens/post_read_screen.dart';
// import 'package:local_buzz_app/screens/search_screen.dart';
// import 'package:provider/provider.dart';

// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({super.key});

//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _selectedIndex = 0;
//   bool hasUnreadNotifications = false;
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void initState() {
//     super.initState();
//     _listenToNotifications();
//   }

//   // 🔴 Listen for unseen notifications
//   void _listenToNotifications() {
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//           setState(() {
//             hasUnreadNotifications = snapshot.docs.isNotEmpty;
//           });
//         });
//   }

//   // ✅ When Notifications tab is opened, mark all as seen
//   Future<void> _markNotificationsAsSeen() async {
//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     for (final doc in query.docs) {
//       doc.reference.update({'seen': true});
//     }
//   }

//   final List<Widget> _screens = [
//     const HomeFeedScreen(key: PageStorageKey('HomeFeed')),
//     const CreateReadScreen(key: PageStorageKey('CreateRead')),
//     const SearchScreen(key: PageStorageKey('Search')),
//     NotificationsTab(key: PageStorageKey('Notifications')),
//     MyProfileScreen(key: PageStorageKey('Profile')),
//   ];

//   void _onItemTapped(int index) {
//     if (index == 3) {
//       // Opened Notifications tab
//       _markNotificationsAsSeen();
//     }
//     setState(() => _selectedIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         currentIndex: _selectedIndex,
//         selectedItemColor: isDark ? Colors.white : Colors.black,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: "Home Feed",
//             tooltip: "Home Feed",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.add_box_outlined),
//             label: "Post",
//             tooltip: "Create Post",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: "Search",
//             tooltip: "Search",
//           ),

//           // BottomNavigationBarItem(
//           //   icon: Stack(
//           //     clipBehavior: Clip.none,
//           //     children: [
//           //       const Icon(Icons.notifications),
//           //       if (hasUnreadNotifications)
//           //         Positioned(
//           //           right: -2,
//           //           top: -2,
//           //           child: Container(
//           //             width: 8,
//           //             height: 8,
//           //             decoration: const BoxDecoration(
//           //               color: Colors.red,
//           //               shape: BoxShape.circle,
//           //             ),
//           //           ),
//           //         ),
//           //     ],
//           //   ),
//           //   label: "Notifications",
//           //   tooltip: "Notifications",
//           // ),
//           BottomNavigationBarItem(
//             icon: Consumer<NotificationSeenProvider>(
//               builder: (context, provider, _) {
//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.notifications),
//                     if (provider.hasUnread)
//                       const Positioned(
//                         right: -2,
//                         top: -2,
//                         child: CircleAvatar(
//                           radius: 4,
//                           backgroundColor: Colors.red,
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//             label: "Notifications",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline_outlined),
//             label: "Profile",
//             tooltip: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }



//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/Notification_screen.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';
// import 'package:local_buzz_app/screens/my_profile_screen.dart';
// import 'package:local_buzz_app/screens/post_read_screen.dart';
// import 'package:local_buzz_app/screens/search_screen.dart';
// import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
// import 'package:provider/provider.dart';

// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({super.key});

//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     const HomeFeedScreen(key: PageStorageKey('HomeFeed')),
//     const CreateReadScreen(key: PageStorageKey('CreateRead')),
//     const SearchScreen(key: PageStorageKey('Search')),
//     const NotificationsTab(key: PageStorageKey('Notifications')),
//     MyProfileScreen(key: PageStorageKey('Profile')),
//   ];

//   void _onItemTapped(int index) {
//     if (index == 3) {
//       // Notifications tab
//       Provider.of<NotificationSeenProvider>(context, listen: false).markAllAsSeen();
//     }
//     setState(() => _selectedIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         currentIndex: _selectedIndex,
//         selectedItemColor: isDark ? Colors.white : Colors.black,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: "Home Feed",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.add_box_outlined),
//             label: "Post",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: "Search",
//           ),
//           BottomNavigationBarItem(
//             icon: Consumer<NotificationSeenProvider>(
//               builder: (context, provider, _) {
//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.notifications),
//                     if (provider.hasUnread)
//                       const Positioned(
//                         right: -2,
//                         top: -2,
//                         child: CircleAvatar(
//                           radius: 4,
//                           backgroundColor: Colors.red,
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//             label: "Notifications",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline_outlined),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/Notification_screen.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';
// import 'package:local_buzz_app/screens/my_profile_screen.dart';
// import 'package:local_buzz_app/screens/post_read_screen.dart';
// import 'package:local_buzz_app/screens/search_screen.dart';
// import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
// import 'package:provider/provider.dart';

// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({super.key});

//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     const HomeFeedScreen(key: PageStorageKey('HomeFeed')),
//     const CreateReadScreen(key: PageStorageKey('CreateRead')),
//     const SearchScreen(key: PageStorageKey('Search')),
//     const NotificationsTab(key: PageStorageKey('Notifications')),
//     MyProfileScreen(key: PageStorageKey('Profile')),
//   ];

//   void _onItemTapped(int index) async{
//     if (index == 3) {
//       // Notifications tab
//       // await Future.delayed(const Duration(milliseconds: 300));
//       // await // Delay to ensure UI updates
//       // Provider.of<NotificationSeenProvider>(context, listen: false).markAllAsSeen();
//     }
//     setState(() => _selectedIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         currentIndex: _selectedIndex,
//         selectedItemColor: isDark ? Colors.white : Colors.black,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: "Home Feed",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.add_box_outlined),
//             label: "Post",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: "Search",
//           ),
//           BottomNavigationBarItem(
//             icon: Consumer<NotificationSeenProvider>(
//               builder: (context, provider, _) {
//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.notifications),
//                     if (provider.hasUnread)
//                       const Positioned(
//                         right: -2,
//                         top: -2,
//                         child: CircleAvatar(
//                           radius: 4,
//                           backgroundColor: Colors.red,
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//             label: "Notifications",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline_outlined),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:local_buzz_app/screens/Notification_screen.dart';
import 'package:local_buzz_app/screens/home_feed_screen.dart';
import 'package:local_buzz_app/screens/my_profile_screen.dart';
//import 'package:local_buzz_app/screens/otherscreens/poll_creation_screen.dart';
//import 'package:local_buzz_app/screens/post_read_screen.dart';
import 'package:local_buzz_app/screens/search_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
import 'package:local_buzz_app/screens/trending_posts_screen.dart';
import 'package:provider/provider.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeFeedScreen(key: PageStorageKey('HomeFeed')),
    const TrendingScreen(key: PageStorageKey('Trending')),
    const SearchScreen(key: PageStorageKey('Search')),
    const NotificationsTab(key: PageStorageKey('Notifications')),
    MyProfileScreen(key: PageStorageKey('Profile')),
  ];

  void _onItemTapped(int index) async{
    setState(() => _selectedIndex = index);
    if(index == 3){
      await Future.delayed(const Duration(milliseconds: 300));

      Provider.of<NotificationSeenProvider>(context, listen: false).markAllAsSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home Feed",
            tooltip: 'Home Feed'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            label: "Trending",
            tooltip: 'Trending'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
            tooltip: 'Search'
          ),
          BottomNavigationBarItem(
            icon: Consumer<NotificationSeenProvider>(
              builder: (context, provider, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    if (provider.hasUnread)
                      const Positioned(
                        right: -2,
                        top: -2,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.red,
                        ),
                      ),
                  ],
                );
              },
            ),
            label: "Notifications",
            tooltip: 'Notifications'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: "Profile",
            tooltip: 'Profile'
          ),
        ],
      ),
    );
  }
}