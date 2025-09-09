// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:local_buzz_app/screens/otherscreens/read_detail_byloc.dart';

// class PostsByLocationScreen extends StatelessWidget {
//   final String location;

//   const PostsByLocationScreen({super.key, required this.location});

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(title: Text("Posts from $location")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('reads')
//             .where('uid', isEqualTo: currentUserId)
//             .where('location', isEqualTo: location)
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final posts = snapshot.data!.docs;

//           if (posts.isEmpty) {
//             return Center(child: Text("No posts from $location."));
//           }

//           return ListView.builder(
//             itemCount: posts.length,
//             itemBuilder: (context, index) {
//               final data = posts[index].data() as Map<String, dynamic>;
//               final text = data['text'] ?? '';

//               return ListTile(
//                 leading: const Icon(Icons.article_outlined),
//                 title: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
//                 subtitle: Text(location),
//                 onTap: (){
//                   Navigator.push(context, MaterialPageRoute(builder: (context)=> ReadDetailScreen(data: data)));
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:local_buzz_app/screens/otherscreens/read_detail_byloc.dart';
// //import 'read_detail_screen.dart'; // your custom screen

// class PostsByLocationScreen extends StatelessWidget {
//   final String location;

//   const PostsByLocationScreen({super.key, required this.location});

//   @override
//   Widget build(BuildContext context) {
//     print("Opening location screen for: $location");

//     return Scaffold(
//       appBar: AppBar(title: Text("Posts from $location")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('reads')
//             .where('location', isEqualTo: location)
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           print("Snapshot state: ${snapshot.connectionState}");

//           if (snapshot.hasError) {
//             print("Error: ${snapshot.error}");
//             return Center(child: Text('Error loading posts'));
//           }

//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final posts = snapshot.data!.docs;

//           if (posts.isEmpty) {
//             return const Center(child: Text("No posts found."));
//           }

//           return ListView.builder(
//             itemCount: posts.length,
//             itemBuilder: (context, index) {
//               final doc = posts[index];
//               final data = doc.data() as Map<String, dynamic>;
//               final text = data['text'] ?? 'No content';

//               return ListTile(
//                 title: Text(
//                   text,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => ReadDetailScreen(data: data),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_buzz_app/screens/otherscreens/read_detail_byloc.dart';

class PostsByLocationScreen extends StatelessWidget {
  final String location;

  const PostsByLocationScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    print("Opening location screen for: $location");

    return Scaffold(
      appBar: AppBar(title: Text("Your Posts from $location")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reads')
            .where('location', isEqualTo: location)
            .where('uid', isEqualTo: currentUserId) // 🔧 filter by user
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print("Snapshot state: ${snapshot.connectionState}");

          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(child: Text('Error loading posts'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(child: Text("No posts found."));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final doc = posts[index];
              final data = doc.data() as Map<String, dynamic>;
              final text = data['text'] ?? 'No content';

              return ListTile(
                title: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadDetailScreen(data: data),
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