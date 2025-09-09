// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:local_buzz_app/screens/user_profile.dart';

// class BookmarksScreen extends StatefulWidget {
//   const BookmarksScreen({super.key});

//   @override
//   State<BookmarksScreen> createState() => _BookmarksScreenState();
// }

// class _BookmarksScreenState extends State<BookmarksScreen> {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   Future<List<DocumentSnapshot>> fetchBookmarkedPosts() async {
//     final bookmarksSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('bookmarks')
//         .get();

//     final postIds = bookmarksSnapshot.docs.map((doc) => doc.id).toList();

//     if (postIds.isEmpty) return [];

//     final postsSnapshot = await FirebaseFirestore.instance
//         .collection('reads')
//         .where(FieldPath.documentId, whereIn: postIds)
//         .orderBy('timestamp', descending: true)
//         .get();

//     return postsSnapshot.docs;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Saved Posts")),
//       body: FutureBuilder<List<DocumentSnapshot>>(
//         future: fetchBookmarkedPosts(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No saved posts."));
//           }

//           final posts = snapshot.data!;
//           return ListView.builder(
//             itemCount: posts.length,
//             itemBuilder: (context, index) {
//               final data = posts[index].data() as Map<String, dynamic>;
//               final text = data['text'] ?? '';
//               final timestamp = data['timestamp']?.toDate();
//               final uid = data['uid'];

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(uid)
//                     .get(),
//                 builder: (context, userSnapshot) {
//                   if (!userSnapshot.hasData) return const SizedBox();

//                   final userData =
//                       userSnapshot.data!.data() as Map<String, dynamic>;
//                   final name = userData['name'] ?? 'User';

//                   return ListTile(
//                     title: Text(text),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("by $name"),
//                         if (timestamp != null)
//                           Text(
//                             timeago.format(timestamp),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                       ],
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => UserProfileScreen(userId: uid),
//                         ),
//                       );
//                     },
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



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class BookmarksScreen extends StatefulWidget {
//   const BookmarksScreen({super.key});

//   @override
//   State<BookmarksScreen> createState() => _BookmarksScreenState();
// }

// class _BookmarksScreenState extends State<BookmarksScreen> {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   Future<List<DocumentSnapshot>> fetchBookmarkedPosts() async {
//     final bookmarksSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('bookmarks')
//         .get();

//     final postIds = bookmarksSnapshot.docs.map((doc) => doc.id).toList();

//     if (postIds.isEmpty) return [];

//     final readsCollection = FirebaseFirestore.instance.collection('reads');
//     final posts = await Future.wait(
//       postIds.map((id) => readsCollection.doc(id).get()),
//     );

//     return posts.where((doc) => doc.exists).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Bookmarks")),
//       body: FutureBuilder<List<DocumentSnapshot>>(
//         future: fetchBookmarkedPosts(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final posts = snapshot.data ?? [];

//           if (posts.isEmpty) {
//             return const Center(child: Text("No bookmarks yet."));
//           }

//           return ListView.builder(
//             itemCount: posts.length,
//             itemBuilder: (context, index) {
//               final data = posts[index].data() as Map<String, dynamic>;
//               final text = data['text'] ?? '';
//               final location = data['location'] ?? '';

//               return ListTile(
//                 title: Text(text),
//                 subtitle: Text(location),
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
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class BookmarksScreen extends StatelessWidget {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   BookmarksScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final bookmarksRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('bookmarks')
//         .orderBy('savedAt', descending: true);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Bookmarked Posts"),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: bookmarksRef.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(child: Text("Something went wrong"));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final bookmarkDocs = snapshot.data!.docs;

//           if (bookmarkDocs.isEmpty) {
//             return const Center(child: Text("No bookmarked posts."));
//           }

//           return ListView.builder(
//             itemCount: bookmarkDocs.length,
//             itemBuilder: (context, index) {
//               final bookmark = bookmarkDocs[index];
//               final postId = bookmark.id;

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('reads')
//                     .doc(postId)
//                     .get(),
//                 builder: (context, postSnap) {
//                   if (!postSnap.hasData || !(postSnap.data?.exists ?? false)) {
//                     return const SizedBox(); // post doesn't exist
//                   }

//                   final postRaw = postSnap.data?.data();
//                   if (postRaw == null || postRaw is! Map<String, dynamic>) {
//                     return const SizedBox(); // avoid crash
//                   }

//                   final text = postRaw['text'] ?? '';
//                   final timestamp = postRaw['timestamp']?.toDate();
//                   final location = postRaw['location'] ?? '';
//                   final uid = postRaw['uid'];

//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(uid)
//                         .get(),
//                     builder: (context, userSnap) {
//                       if (!userSnap.hasData ||
//                           !(userSnap.data?.exists ?? false)) {
//                         return const SizedBox();
//                       }

//                       final userRaw = userSnap.data?.data();
//                       if (userRaw == null || userRaw is! Map<String, dynamic>) {
//                         return const SizedBox();
//                       }

//                       final name = userRaw['name'] ?? 'User';

//                       return ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 10,
//                         ),
//                         title: Text(text),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Posted by: $name"),
//                             if (timestamp != null)
//                               Text(
//                                 timeago.format(timestamp),
//                                 style: const TextStyle(fontSize: 12),
//                               ),
//                             if (location.isNotEmpty)
//                               Text(
//                                 location,
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.grey),
//                               ),
//                           ],
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.bookmark_remove_outlined),
//                           onPressed: () async {
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(currentUserId)
//                                 .collection('bookmarks')
//                                 .doc(postId)
//                                 .delete();

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Removed from bookmarks"),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
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
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:local_buzz_app/screens/otherscreens/bookmarks_provider.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarked Posts"),
      ),
      body: Consumer<BookmarksProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.bookmarks.isEmpty) {
            return const Center(child: Text("No bookmarked posts."));
          }

          return ListView.builder(
            itemCount: provider.bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = provider.bookmarks[index];
              final postId = bookmark.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('reads')
                    .doc(postId)
                    .get(),
                builder: (context, postSnap) {
                  if (!postSnap.hasData || !(postSnap.data?.exists ?? false)) {
                    return const SizedBox();
                  }

                  final postRaw = postSnap.data!.data() as Map<String, dynamic>;
                  final text = postRaw['text'] ?? '';
                  final timestamp = postRaw['timestamp']?.toDate();
                  final location = postRaw['location'] ?? '';
                  final uid = postRaw['uid'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData ||
                          !(userSnap.data?.exists ?? false)) {
                        return const SizedBox();
                      }

                      final userRaw =
                          userSnap.data!.data() as Map<String, dynamic>;
                      final name = userRaw['name'] ?? 'User';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: Text(text),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Posted by: $name"),
                            if (timestamp != null)
                              Text(
                                timeago.format(timestamp),
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (location.isNotEmpty)
                              Text(
                                location,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_remove_outlined),
                          onPressed: () async {
                            await Provider.of<BookmarksProvider>(
                              context,
                              listen: false,
                            ).removeBookmark(postId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Removed from bookmarks"),
                              ),
                            );
                          },
                        ),
                      );
                    },
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