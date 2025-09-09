import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_buzz_app/screens/otherscreens/postby_location_screen.dart';
//import 'posts_by_location_screen.dart'; // Create this

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Locations")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reads')
            .where('uid', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final posts = snapshot.data!.docs;

          // Extract unique locations
          final locations = posts
              .map((doc) => doc['location'] ?? '')
              .where((loc) => loc != '')
              .toSet()
              .toList();

          if (locations.isEmpty) {
            return const Center(child: Text("No saved locations yet."));
          }

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(location),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostsByLocationScreen(location: location),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}