// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// //import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math';
// import 'package:local_buzz_app/screens/user_profile.dart';

// class SearchUsersScreen extends StatefulWidget {
//   const SearchUsersScreen({super.key});

//   @override
//   State<SearchUsersScreen> createState() => _SearchUsersScreenState();
// }

// class _SearchUsersScreenState extends State<SearchUsersScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<QueryDocumentSnapshot> _filteredResults = [];
//   Position? currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//     _searchController.addListener(() {
//       if (currentPosition != null) {
//         searchUsers(_searchController.text);
//       }
//     });
//   }

//   Future<void> getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) return;

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.deniedForever ||
//           permission == LocationPermission.denied) {
//         return;
//       }

//       currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       print("Location error: $e");
//     }
//   }

//   void searchUsers(String query) async {
//     final trimmed = query.trim().toLowerCase();
//     if (trimmed.isEmpty || currentPosition == null) {
//       setState(() {
//         _filteredResults = [];
//       });
//       return;
//     }

//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .where('nameLower', isGreaterThanOrEqualTo: trimmed)
//         .where('nameLower', isLessThanOrEqualTo: '$trimmed\uf8ff')
//         .get();

//     final List<QueryDocumentSnapshot> results = [];

//     for (final doc in snapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final geo = data['geo']; // assuming user has geo field in their profile

//       if (geo != null) {
//         final distance = calculateDistance(
//           currentPosition!.latitude,
//           currentPosition!.longitude,
//           geo.latitude,
//           geo.longitude,
//         );
//         if (distance <= 100) {
//           results.add(doc);
//         }
//       }
//     }

//     setState(() {
//       _filteredResults = results;
//     });
//   }

//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     const R = 6371;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a =
//         sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) *
//             cos(_deg2rad(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Search Users")),
//       body: currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: "Search users by name...",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.search),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Expanded(
//                     child: _filteredResults.isEmpty
//                         ? const Center(child: Text("No users found nearby."))
//                         : ListView.builder(
//                             itemCount: _filteredResults.length,
//                             itemBuilder: (context, index) {
//                               final user =
//                                   _filteredResults[index].data() as Map;
//                               return ListTile(
//                                 leading: const CircleAvatar(
//                                   child: Icon(Icons.person),
//                                 ),
//                                 title: Text(user['name'] ?? 'User'),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => UserProfileScreen(
//                                         userId: _filteredResults[index].id,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:local_buzz_app/screens/user_profile.dart';
// import 'dart:math';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController searchController = TextEditingController();
//   Position? currentPosition;
//   List<QueryDocumentSnapshot> allUsers = [];
//   List<QueryDocumentSnapshot> filteredUsers = [];

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//     fetchUsers();
//   }

//   Future<void> getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {});
//     } catch (e) {
//       print("Location error: $e");
//     }
//   }

//   Future<void> fetchUsers() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance.collection('users').get();
//       final currentUid = FirebaseAuth.instance.currentUser!.uid;

//       allUsers = snapshot.docs.where((doc) {
//         final uid = doc['uid'];
//         final geo = doc['geo'];
//         if (uid == currentUid || geo == null || currentPosition == null) return false;

//         final distance = calculateDistance(
//           currentPosition!.latitude,
//           currentPosition!.longitude,
//           geo.latitude,
//           geo.longitude,
//         );
//         return distance <= 100;
//       }).toList();

//       setState(() {});
//     } catch (e) {
//       print("Fetch users error: $e");
//     }
//   }

//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     const R = 6371;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
//         sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   void onSearchChanged(String query) {
//     query = query.toLowerCase();
//     setState(() {
//       filteredUsers = allUsers.where((doc) {
//         final name = doc['nameLower'] ?? '';
//         final username = doc['username'] ?? '';
//         return name.contains(query) || username.contains(query);
        
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search Users"),
//         centerTitle: true,
//       ),
//       body: currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     onChanged: onSearchChanged,
//                     decoration: InputDecoration(
//                       hintText: "Search by name...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: filteredUsers.isEmpty
//                         ? const Center(child: Text("No users found"))
//                         : ListView.builder(
//                             itemCount: filteredUsers.length,
//                             itemBuilder: (context, index) {
//                               final user = filteredUsers[index];
//                               return ListTile(
//                                 leading: const CircleAvatar(
//                                   child: Icon(Icons.person),
//                                 ),
//                                 title: Text(user['name']),
//                                 subtitle: Text(user['email'] ?? ''),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) =>
//                                           UserProfileScreen(userId: user['uid']),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:local_buzz_app/screens/user_profile.dart';
// import 'dart:math';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//   Position? currentPosition;
//   List<QueryDocumentSnapshot> allUsers = [];
//   List<QueryDocumentSnapshot> filteredUsers = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchLocationAndUsers();
//   }

//   Future<void> fetchLocationAndUsers() async {
//     try {
//       // Get permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       final snapshot = await FirebaseFirestore.instance.collection('users').get();
//       final currentUid = FirebaseAuth.instance.currentUser!.uid;

//       allUsers = snapshot.docs.where((doc) {
//         final uid = doc['uid'];
//         final geo = doc['geo'];

//         if (uid == currentUid || geo == null || currentPosition == null) return false;

//         final distance = calculateDistance(
//           currentPosition!.latitude,
//           currentPosition!.longitude,
//           geo.latitude,
//           geo.longitude,
//         );
//         return distance <= 100;
//       }).toList();

//       setState(() {
//         isLoading = false;
//         filteredUsers = allUsers;
//       });
//     } catch (e) {
//       print("Error fetching location or users: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     const R = 6371;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
//         sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   void onSearchChanged(String query) {
//     query = query.toLowerCase();
//     setState(() {
//       filteredUsers = allUsers.where((doc) {
//         final name = (doc['nameLower'] ?? '').toString();
//         final username = (doc['username'] ?? '').toString();
//         return name.contains(query) || username.toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search Users"),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     onChanged: onSearchChanged,
//                     decoration: InputDecoration(
//                       hintText: "Search by name or username...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: filteredUsers.isEmpty
//                         ? const Center(child: Text("No users found"))
//                         : ListView.builder(
//                             itemCount: filteredUsers.length,
//                             itemBuilder: (context, index) {
//                               final user = filteredUsers[index];
//                               return ListTile(
//                                 leading: const CircleAvatar(
//                                   child: Icon(Icons.person),
//                                 ),
//                                 title: Text(user['name'] ?? ''),
//                                 subtitle: Text(user['username'] ?? ''),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) =>
//                                           UserProfileScreen(userId: user['uid']),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math';

// import 'user_profile.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController searchController = TextEditingController();
//   Position? currentPosition;
//   List<QueryDocumentSnapshot> allUsers = [];
//   List<QueryDocumentSnapshot> filteredUsers = [];
//   bool isFetching = true;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//   }

//   Future<void> getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       await fetchUsers();
//     } catch (e) {
//       print("Location error: $e");
//       setState(() => isFetching = false);
//     }
//   }

//   Future<void> fetchUsers() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance.collection('users').get();
//       final currentUid = FirebaseAuth.instance.currentUser!.uid;

//       allUsers = snapshot.docs.where((doc) {
//         final uid = doc['uid'];
//         final geo = doc['geo'];
//         if (uid == currentUid || geo == null || currentPosition == null) return false;

//         final distance = calculateDistance(
//           currentPosition!.latitude,
//           currentPosition!.longitude,
//           geo.latitude,
//           geo.longitude,
//         );
//         return distance <= 100;
//       }).toList();

//       filteredUsers = allUsers; // initially show all in 100km
//     } catch (e) {
//       print("Fetch users error: $e");
//     }

//     setState(() => isFetching = false);
//   }

//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     const R = 6371;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
//         sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   void onSearchChanged(String query) {
//     query = query.toLowerCase();
//     setState(() {
//       filteredUsers = allUsers.where((doc) {
//         final nameLower = doc['nameLower'] ?? '';
//         final username = doc['username'] ?? '';
//         return nameLower.contains(query) || username.toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search Users"),
//         centerTitle: true,
//       ),
//       body: isFetching || currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     onChanged: onSearchChanged,
//                     onSubmitted: onSearchChanged,
//                     textInputAction: TextInputAction.search,
//                     decoration: InputDecoration(
//                       hintText: "Search by name or username...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: filteredUsers.isEmpty
//                         ? const Center(child: Text("No users found"))
//                         : ListView.builder(
//                             itemCount: filteredUsers.length,
//                             itemBuilder: (context, index) {
//                               final user = filteredUsers[index];
//                               return ListTile(
//                                 leading: const CircleAvatar(
//                                   child: Icon(Icons.person),
//                                 ),
//                                 title: Text(user['name']),
//                                 subtitle: Text(user['email'] ?? ''),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => UserProfileScreen(userId: user['uid']),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }





// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:local_buzz_app/screens/user_profile.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   Position? currentPosition;
//   List<QueryDocumentSnapshot> allUsers = [];
//   List<QueryDocumentSnapshot> filteredUsers = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocationAndUsers();
//   }

//   Future<void> getCurrentLocationAndUsers() async {
//     try {
//       // Step 1: Get location
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       // Step 2: Fetch all users
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .get();

//       allUsers = snapshot.docs.where((doc) {
//         final uid = doc['uid'];
//         final geo = doc['geo'];
//         if (uid == currentUserId || geo == null || currentPosition == null) return false;

//         final distance = calculateDistance(
//           currentPosition!.latitude,
//           currentPosition!.longitude,
//           geo.latitude,
//           geo.longitude,
//         );
//         return distance <= 100;
//       }).toList();

//       // Show all users by default
//       filteredUsers = List.from(allUsers);
//     } catch (e) {
//       print("Error: $e");
//     }

//     setState(() => isLoading = false);
//   }

//   void onSearchChanged(String value) {
//     final query = value.trim().toLowerCase();
//     setState(() {
//       filteredUsers = allUsers.where((doc) {
//         final name = doc['namelower'] ?? '';
//         final username = doc['username'] ?? '';
//         return name.contains(query) || username.toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     const R = 6371;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
//         sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search Users"),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     onChanged: onSearchChanged,
//                     textInputAction: TextInputAction.search,
//                     decoration: InputDecoration(
//                       hintText: "Search by name or username...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: filteredUsers.isEmpty
//                         ? const Center(child: Text("No users found"))
//                         : ListView.builder(
//                             itemCount: filteredUsers.length,
//                             itemBuilder: (context, index) {
//                               final user = filteredUsers[index];
//                               return ListTile(
//                                 leading: const CircleAvatar(
//                                   child: Icon(Icons.person),
//                                 ),
//                                 title: Text(user['name'] ?? ''),
//                                 subtitle: Text(user['username'] ?? ''),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => UserProfileScreen(userId: user['uid']),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }




// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:local_buzz_app/screens/user_profile.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final searchController = TextEditingController();
//   Position? currentPosition;
//   bool isLoading = false;

//   List<QueryDocumentSnapshot> allUsers = [];
//   List<QueryDocumentSnapshot> filteredUsers = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     setState(() => isLoading = true);
//     await getCurrentLocation();
//     await fetchUsers();
//     setState(() => isLoading = false);
//   }

//   Future<void> getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//     } catch (e) {
//       print("Location error: $e");
//     }
//   }

//   Future<void> fetchUsers() async {
//     try {
//       final currentUid = FirebaseAuth.instance.currentUser!.uid;
//       final snapshot = await FirebaseFirestore.instance.collection('users').get();

//       allUsers = snapshot.docs.where((doc) {
//         if (doc['uid'] == currentUid) return false;

//         // Safe check for geo
//         final geo = doc.data().containsKey('geo') ? doc['geo'] : null;
//         if (geo == null || currentPosition == null) return false;

//         final distance = calculateDistance(
//           currentPosition!.latitude,
//           currentPosition!.longitude,
//           geo.latitude,
//           geo.longitude,
//         );

//         return distance <= 100;
//       }).toList();

//       filteredUsers = List.from(allUsers); // show all initially
//     } catch (e) {
//       print("Fetch users error: $e");
//     }
//   }

//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     const R = 6371;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
//         sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   // void onSearchChanged(String query) {
//   //   query = query.toLowerCase();

//   //   setState(() {
//   //     filteredUsers = allUsers.where((doc) {
//   //       final nameLower = doc.data().containsKey('namelower')
//   //           ? doc['namelower']
//   //           : (doc['name'] ?? '').toString().toLowerCase();

//   //       return nameLower.contains(query);
//   //     }).toList();
//   //   });
//   // }
//   void onSearchChanged(String query) {
//   query = query.toLowerCase().trim();

//   setState(() {
//     filteredUsers = allUsers.where((doc) {
//       final data = doc.data() as Map<String, dynamic>?;

//       if (data == null) return false;

//       final nameLower = data['namelower']?.toString().toLowerCase() ?? '';
//       final username = data['username']?.toString().toLowerCase() ?? '';

//       return nameLower.contains(query) || username.contains(query);
//     }).toList();
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search Users"),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     onChanged: onSearchChanged,
//                     decoration: InputDecoration(
//                       hintText: "Search by name...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: filteredUsers.isEmpty
//                         ? const Center(child: Text("No users found"))
//                         : ListView.builder(
//                             itemCount: filteredUsers.length,
//                             itemBuilder: (context, index) {
//                               final user = filteredUsers[index];
//                               return ListTile(
//                                 leading: const CircleAvatar(
//                                   child: Icon(Icons.person),
//                                 ),
//                                 title: Text(user['name'] ?? ''),
//                                 subtitle: Text(user['email'] ?? ''),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => UserProfileScreen(userId: user['uid']),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:local_buzz_app/screens/private_user_profie.dart';
// import 'package:local_buzz_app/screens/public_user_pofile.dart';
// //import 'package:local_buzz_app/screens/user_profile.dart';
// import 'dart:math';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//   Position? currentPosition;
//   List<QueryDocumentSnapshot> allUsers = [];
//   List<QueryDocumentSnapshot> filteredUsers = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     initSearch();
//   }

//   Future<void> initSearch() async {
//     await getCurrentLocation();
//     await fetchUsers();
//     setState(() => isLoading = false);
//   }

//   Future<void> getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//     } catch (e) {
//       print("Location error: $e");
//     }
//   }

//   Future<void> fetchUsers() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance.collection('users').get();
//       final currentUid = FirebaseAuth.instance.currentUser!.uid;

//       allUsers = snapshot.docs.where((doc) {
//         final uid = doc['uid'];
//         final geo = doc.data().containsKey('geo') ? doc['geo'] : null;

//         if (uid == currentUid || geo == null || currentPosition == null) return false;

//         try {
//           final distance = calculateDistance(
//             currentPosition!.latitude,
//             currentPosition!.longitude,
//             geo.latitude,
//             geo.longitude,
//           );
//           return distance <= 100;
//         } catch (e) {
//           return false;
//         }
//       }).toList();
//     } catch (e) {
//       print("Fetch users error: $e");
//     }
//   }

//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     const R = 6371;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
//         sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   void onSearchChanged(String query) {
//     query = query.toLowerCase().trim();

//     if (query.isEmpty) {
//       setState(() => filteredUsers = []);
//       return;
//     }

//     final results = allUsers.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       final nameLower = data['namelower'] ?? '';
//       final username = data['username'] ?? '';
//       return nameLower.toString().contains(query) ||
//           username.toString().toLowerCase().contains(query);
//     }).toList();

//     setState(() => filteredUsers = results);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search Users"),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//              Navigator.push(context, MaterialPageRoute(builder: (context)=> PrivateProfileScreen()));
//             },
//           ),
//         ],
//       ),
//       body: isLoading || currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     onChanged: onSearchChanged,
//                     decoration: InputDecoration(
//                       hintText: "Search by name or username...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: filteredUsers.isEmpty && searchController.text.isNotEmpty
//                         ? const Center(child: Text("No users found"))
//                         : ListView.builder(
//                             itemCount: filteredUsers.length,
//                             itemBuilder: (context, index) {
//                               final user = filteredUsers[index];
//                               final userData = user.data() as Map<String, dynamic>;

//                               return ListTile(
//                                 leading: const CircleAvatar(child: Icon(Icons.person)),
//                                 title: Text(userData['name'] ?? 'No Name'),
//                                 subtitle: Text(userData['email'] ?? ''),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) =>
//                                           PublicProfileScreen(userId: userData['uid']),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }




//PROVIDER USE

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_buzz_app/screens/private_user_profie.dart';
import 'package:local_buzz_app/screens/public_user_pofile.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider()..initSearch(),
      child: const SearchScreenBody(),
    );
  }
}

class SearchScreenBody extends StatefulWidget {
  const SearchScreenBody({super.key});

  @override
  State<SearchScreenBody> createState() => _SearchScreenBodyState();
}

class _SearchScreenBodyState extends State<SearchScreenBody> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Search Users"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivateProfileScreen()));
                },
              ),
            ],
          ),
          body: provider.isLoading || provider.currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: provider.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search by name or username...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: provider.filteredUsers.isEmpty && searchController.text.isNotEmpty
                            ? const Center(child: Text("No users found"))
                            : ListView.builder(
                                itemCount: provider.filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = provider.filteredUsers[index];
                                  final userData = user.data() as Map<String, dynamic>;
                                  return ListTile(
                                    leading: const CircleAvatar(child: Icon(Icons.person)),
                                    title: Text(userData['name'] ?? 'No Name'),
                                    subtitle: Text(userData['username'] ?? ''),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PublicProfileScreen(userId: userData['uid']),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

// ✅ SearchProvider to manage state
class SearchProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> allUsers = [];
  List<QueryDocumentSnapshot> filteredUsers = [];
  Position? currentPosition;
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initSearch() async {
    await getCurrentLocation();
    await fetchUsers();
    filteredUsers=[];
    isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Location error: $e");
    }
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final currentUid = _auth.currentUser!.uid;

      allUsers = snapshot.docs.where((doc) {
        final uid = doc['uid'];
        final geo = doc.data().containsKey('geo') ? doc['geo'] : null;

        if (uid == currentUid || geo == null || currentPosition == null) return false;

        try {
          final distance = calculateDistance(
            currentPosition!.latitude,
            currentPosition!.longitude,
            geo.latitude,
            geo.longitude,
          );
          return distance <= 100;
        } catch (e) {
          return false;
        }
      }).toList();

      filteredUsers = allUsers;
      notifyListeners();
    } catch (e) {
      print("Fetch users error: $e");
    }
  }

  void onSearchChanged(String query) {
    query = query.toLowerCase().trim();

    if (query.isEmpty) {
      filteredUsers = [];
    } else {
      filteredUsers = allUsers.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final nameLower = data['namelower'] ?? '';
        final username = data['username'] ?? '';
        return nameLower.toString().contains(query) ||
            username.toString().toLowerCase().contains(query);
      }).toList();
    }

    notifyListeners();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}