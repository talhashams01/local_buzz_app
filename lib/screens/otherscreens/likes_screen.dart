// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// //import 'package:local_buzz_app/screens/user_profile.dart';
// //import 'user_profile.dart';

// class LikesScreen extends StatelessWidget {
//   final String postId;

//   const LikesScreen({Key? key, required this.postId}) : super(key: key); // ✅ named & required

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Liked by")),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('reads')
//             .doc(postId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           final List likes = data['likes'] ?? [];

//           if (likes.isEmpty) {
//             return const Center(child: Text("No likes yet."));
//           }

//           return ListView.builder(
//       //       itemCount: likes.length,
//       //       itemBuilder: (context, index) {
//       //         final userId = likes[index];
//       //         return FutureBuilder<DocumentSnapshot>(
//       //           future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
//       //           builder: (context, userSnapshot) {
//       //             if (!userSnapshot.hasData) return const SizedBox();
//       //             final userData = userSnapshot.data!.data() as Map<String, dynamic>;
//       //             final name = userData['name'] ?? 'User';

//       //             return ListTile(
//       //               title: Text(name),
//       //               subtitle: Text("liked this post"),
//       //               onTap: () {
//       //                 Navigator.push(
//       //                   context,
//       //                   MaterialPageRoute(
//       //                     builder: (_) => UserProfileScreen(userId: userId),
//       //                   ),
//       //                 );
//       //               },
//       //             );
//       //           },
//       //         );
//       //       },
//       //     );
//       //   },
//       // ),
    
//     itemCount: likes.length,
// itemBuilder: (context, index) {
//   final userId = likes[index];
//   if (userId == null || userId is! String) return const SizedBox(); // ✅ null-safe

//   return FutureBuilder<DocumentSnapshot>(
//     future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
//     builder: (context, userSnapshot) {
//       if (!userSnapshot.hasData || !userSnapshot.data!.exists) return const SizedBox();
//       final userData = userSnapshot.data!.data() as Map<String, dynamic>;
//       final name = userData['name'] ?? 'User';

//       return ListTile(
//         title: Text(name),
//         subtitle: const Text("liked this post"),
//         // onTap: () {
//         //   Navigator.push(
//         //     context,
//         //     MaterialPageRoute(
//         //       builder: (_) => UserProfileScreen(userId: userId),
//         //     ),
//         //   );
//         // },
//       );
//     },
//   );
// }
//       );
//     },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:local_buzz_app/screens/otherscreens/likes_provider.dart';
import 'package:provider/provider.dart';
//import 'package:local_buzz_app/screens/otherscreens/providers/likes_provider.dart';

class LikesScreen extends StatefulWidget {
  final String postId;

  const LikesScreen({Key? key, required this.postId, }) : super(key: key);

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<LikesProvider>(context, listen: false);
    provider.fetchLikes(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liked by")),
      body: Consumer<LikesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.likedUsers.isEmpty) {
            return const Center(child: Text("No likes yet."));
          }

          return ListView.builder(
            itemCount: provider.likedUsers.length,
            itemBuilder: (context, index) {
              final user = provider.likedUsers[index];

              return ListTile(
                title: Text(user['name']),
                subtitle: const Text("liked this post"),
                // Optionally add onTap for profile
              );
            },
          );
        },
      ),
    );
  }
}