// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class TrendingScreen extends StatelessWidget {
//   const TrendingScreen({super.key});

//   Stream<List<Map<String, dynamic>>> getTrendingPosts() async* {
//     final twoDaysAgo = Timestamp.fromDate(
//       DateTime.now().subtract(const Duration(hours: 48)),
//     );

//     final readsSnap = await FirebaseFirestore.instance
//         .collection('reads')
//         .where('timestamp', isGreaterThan: twoDaysAgo)
//         .get();

//     final pollsSnap = await FirebaseFirestore.instance
//         .collection('polls')
//         .where('timestamp', isGreaterThan: twoDaysAgo)
//         .get();

//     List<Map<String, dynamic>> trendingPosts = [];

//     // Process reads
//     for (var doc in readsSnap.docs) {
//       final data = doc.data();
//       final likes = (data['likes'] ?? []) as List;

//       // Get comment count from subcollection
//       final commentsSnapshot = await FirebaseFirestore.instance
//           .collection('reads')
//           .doc(doc.id)
//           .collection('comments')
//           .get();

//       final comments = commentsSnapshot.docs.length;

//       if (likes.isNotEmpty && comments >= 1) {
//         data['type'] = 'read';
//         data['id'] = doc.id;
//         data['score'] = likes.length + comments;
//         trendingPosts.add(data);
//       }
//     }

//     // Process polls
//     for (var doc in pollsSnap.docs) {
//       final data = doc.data();
//       final votes = (data['votes'] ?? []) as List;

//       final totalVotes = votes.fold<int>(0, (sum, v) => sum + ((v ?? 0) as int));

//       if (totalVotes > 1) {
//         data['type'] = 'poll';
//         data['id'] = doc.id;
//         data['score'] = totalVotes;
//         trendingPosts.add(data);
//       }
//     }

//     // Sort by score descending
//     trendingPosts.sort((a, b) => b['score'].compareTo(a['score']));

//     yield trendingPosts;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("🔥 Trending Buzz")),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: getTrendingPosts(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final posts = snapshot.data ?? [];

//           if (posts.isEmpty) {
//             return const Center(child: Text("No trending posts found."));
//           }

//           return ListView.builder(
//             itemCount: posts.length,
//             itemBuilder: (context, index) {
//               final post = posts[index];
//               final isRead = post['type'] == 'read';
//               final text = isRead ? post['text'] : post['question'];
//               final timestamp = post['timestamp'] as Timestamp;

//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ListTile(
//                   title: Text(
//                     text ?? '',
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   subtitle: Text(
//                     "${isRead ? 'Read' : 'Poll'} · ${timeago.format(timestamp.toDate())}",
//                   ),
//                   trailing: Icon(
//                     isRead ? Icons.book : Icons.poll,
//                     color: Colors.blue,
//                   ),
//                   onTap: () {
//                     // You can implement read or poll detail screens here
//                   },
//                 ),
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
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter/services.dart';

// class TrendingScreen extends StatelessWidget {
//   const TrendingScreen({super.key});

//   Stream<List<Map<String, dynamic>>> getTrendingReads() async* {
//     final now = Timestamp.now();
//     final twoDaysAgo = Timestamp.fromDate(
//       DateTime.now().subtract(const Duration(hours: 48)),
//     );

//     final readSnapshots = FirebaseFirestore.instance
//         .collection('reads')
//         .where('timestamp', isGreaterThan: twoDaysAgo)
//         .snapshots();

//     await for (final snapshot in readSnapshots) {
//       final List<Map<String, dynamic>> filteredReads = [];

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final likes = List.from(data['likes'] ?? []);
//         final commentsSnapshot = await doc.reference.collection('comments').get();

//         if (likes.length >= 5 && commentsSnapshot.docs.length >= 1) {
//           data['id'] = doc.id;
//           data['commentsCount'] = commentsSnapshot.docs.length;
//           filteredReads.add(data);
//         }
//       }

//       filteredReads.sort((a, b) {
//         final likesA = (a['likes'] as List).length;
//         final likesB = (b['likes'] as List).length;
//         return likesB.compareTo(likesA);
//       });

//       yield filteredReads;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: const Text("🔥 Trending Reads")),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: getTrendingReads(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final posts = snapshot.data ?? [];

//           if (posts.isEmpty) {
//             return const Center(child: Text("No trending reads found."));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: posts.length,
//             itemBuilder: (context, index) {
//               final post = posts[index];
//               final timestamp = post['timestamp'] as Timestamp;
//               final likes = post['likes'] as List;
//               final commentsCount = post['commentsCount'] ?? 0;

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// Header
//                       Row(
//                         children: [
//                           const CircleAvatar(child: Icon(Icons.person)),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   post['username'] ?? 'Unknown',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 Text(
//                                   post['location'] ?? 'Unknown',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 timeago.format(timestamp.toDate()),
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               PopupMenuButton<String>(
//                                 onSelected: (value) async {
//                                   final text = post['text'] ?? '';
//                                   if (value == 'copy') {
//                                     await Clipboard.setData(ClipboardData(text: text));
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text("Copied to clipboard")),
//                                     );
//                                   } else if (value == 'share') {
//                                     await Share.share(text);
//                                   } else if (value == 'bookmark') {
//                                     // Add bookmark logic here
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text("Bookmarked")),
//                                     );
//                                   }
//                                 },
//                                 itemBuilder: (context) => [
//                                   const PopupMenuItem(value: 'copy', child: Text("Copy")),
//                                   const PopupMenuItem(value: 'share', child: Text("Share")),
//                                   const PopupMenuItem(value: 'bookmark', child: Text("Bookmark")),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 12),

//                       /// Read Text
//                       Text(
//                         post['text'] ?? '',
//                         style: const TextStyle(fontSize: 16),
//                       ),

//                       const SizedBox(height: 12),

//                       /// Likes & Comments Row
//                       Row(
//                         children: [
//                           const Icon(Icons.thumb_up, size: 18, color: Colors.blue),
//                           const SizedBox(width: 4),
//                           Text("${likes.length}"),

//                           const SizedBox(width: 16),

//                           const Icon(Icons.comment, size: 18, color: Colors.green),
//                           const SizedBox(width: 4),
//                           Text("$commentsCount"),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
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
// //import 'package:local_buzz_app/screens/otherscreens/bookmarks_provider.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:local_buzz_app/screens/otherscreens/comment_screen.dart';
// import 'package:local_buzz_app/screens/otherscreens/likes_screen.dart';
// //import 'package:local_buzz_app/widget/bookmark_service.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter/services.dart';

// class TrendingScreen extends StatelessWidget {
//   const TrendingScreen({super.key});

//   Stream<List<Map<String, dynamic>>> getTrendingReads() async* {
//     final now = DateTime.now();
//     final twoDaysAgo = now.subtract(const Duration(hours: 48));
//     final cutoff = Timestamp.fromDate(twoDaysAgo);
//     final currentUser = FirebaseAuth.instance.currentUser;
//     final readsSnap = FirebaseFirestore.instance
//         .collection('reads')
//         .where('timestamp', isGreaterThan: cutoff)
//         .orderBy('timestamp', descending: true)
//         .snapshots();

//     await for (final snap in readsSnap) {
//       final List<Map<String, dynamic>> filteredReads = [];

//       for (var doc in snap.docs) {
//         final data = doc.data();
//         final likes = (data['likes'] as List?)?.length ?? 0;
//         final uid = data['uid'];
//         final docId = doc.id;

//         // Fetch comments
//         final commentSnap = await FirebaseFirestore.instance
//             .collection('reads')
//             .doc(docId)
//             .collection('comments')
//             .get();

//         final validComments = commentSnap.docs
//             .where((c) => c.data()['uid'] != uid)
//             .toList();

//         final commentCount = validComments.length;

//         if (likes >= 5 && commentCount >= 1) {
//           data['id'] = docId;
//           data['likesCount'] = likes;
//           data['commentsCount'] = commentCount;
//           filteredReads.add(data);
//         }
//       }

//       yield filteredReads;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(title: const Text("🔥 Trending Reads")),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: getTrendingReads(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final reads = snapshot.data ?? [];

//           if (reads.isEmpty) {
//             return const Center(child: Text("No trending reads found."));
//           }

//           return ListView.builder(
//             itemCount: reads.length,
//             itemBuilder: (context, index) {
//               final read = reads[index];
//               final text = read['text'] ?? '';
//               final timestamp = read['timestamp'] as Timestamp;
//               final userId = read['uid'];
//               final location = read['location'] ?? 'Unknown';
//               final docId = read['id'];
//               final likes = read['likes'] ?? [];
//               final commentsCount = read['commentsCount'] ?? 0;

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
//                 builder: (context, userSnap) {
//                   final userData = userSnap.data?.data() as Map<String, dynamic>?;

//                   final name = userData?['name'] ?? "Unknown";
//                   final profilePic = userData?['profilePic'] ?? '';

//                   final isLiked = likes.contains(currentUserId);

//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     elevation: 3,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundImage: profilePic.isNotEmpty
//                                     ? NetworkImage(profilePic)
//                                     : null,
//                                 child: profilePic.isEmpty ? Text(name[0]) : null,
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                                     Text(
//                                       timeago.format(timestamp.toDate()),
//                                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Text(location, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Text(text, style: const TextStyle(fontSize: 16)),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => LikesScreen( postId: docId,),
//                                         ),
//                                       );
//                                     },
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.favorite,
//                                             color: isLiked ? Colors.red : Colors.grey),
//                                         const SizedBox(width: 8),
//                                         Text('${likes.length}'),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   InkWell(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => CommentScreen( postId: docId,),
//                                         ),
//                                       );
//                                     },
//                                     child: Row(
//                                       children: [
//                                         const Icon(Icons.add_comment, color: Colors.grey),
//                                         const SizedBox(width: 8),
//                                         Text('$commentsCount'),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               PopupMenuButton<String>(
//                                 onSelected: (value) async {
//                                   if (value == 'copy') {
//                                     await Clipboard.setData(ClipboardData(text: text));
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text("Copied to clipboard")),
//                                     );
//                                   } else if (value == 'share') {
//                                     await Share.share(text);
//                                   }

//                                 },
//                                 itemBuilder: (context) => [
//                                   const PopupMenuItem(value: 'copy', child: Text("Copy")),
//                                   const PopupMenuItem(value: 'share', child: Text("Share")),
//                                   const PopupMenuItem(value: 'bookmark', child: Text("Bookmark")),
//                                 ],
//                               )
//                             ],
//                           )
//                         ],
//                       ),
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

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:local_buzz_app/screens/otherscreens/comment_screen.dart';
// import 'package:local_buzz_app/screens/otherscreens/likes_screen.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter/services.dart';

// class TrendingScreen extends StatelessWidget {
//   const TrendingScreen({super.key});

//   Stream<List<DocumentSnapshot>> getTrendingReadsStream() {
//     final cutoff = Timestamp.fromDate(
//       DateTime.now().subtract(const Duration(hours: 48)),
//     );

//     return FirebaseFirestore.instance
//         .collection('reads')
//         .where('timestamp', isGreaterThan: cutoff)
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(title: const Text("🔥 Trending Reads")),
//       body: StreamBuilder<List<DocumentSnapshot>>(
//         stream: getTrendingReadsStream(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final reads = snapshot.data!;

//           return ListView.builder(
//             itemCount: reads.length,
//             itemBuilder: (context, index) {
//               final read = reads[index];
//               final data = read.data() as Map<String, dynamic>;
//               final readId = read.id;
//               final userId = data['uid'];
//               final likes = (data['likes'] ?? []) as List;
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final location = data['location'] ?? 'Unknown';
//               final text = data['text'] ?? '';

//               if (likes.length < 5) return const SizedBox(); // Skip if not enough likes

//               return StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('reads')
//                     .doc(readId)
//                     .collection('comments')
//                     .snapshots(),
//                 builder: (context, commentSnapshot) {
//                   if (!commentSnapshot.hasData) return const SizedBox();

//                   final comments = commentSnapshot.data!.docs
//                       .where((c) => c['uid'] != userId)
//                       .toList();

//                   if (comments.length < 1) return const SizedBox(); // Skip if not enough other-user comments

//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
//                     builder: (context, userSnap) {
//                       final userData = userSnap.data?.data() as Map<String, dynamic>?;

//                       final name = userData?['name'] ?? "Unknown";
//                       final profilePic = userData?['profilePic'] ?? '';
//                       final isLiked = likes.contains(currentUserId);

//                       return Card(
//                         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         elevation: 3,
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   CircleAvatar(
//                                     backgroundImage: profilePic.isNotEmpty
//                                         ? NetworkImage(profilePic)
//                                         : null,
//                                     child: profilePic.isEmpty ? Text(name[0]) : null,
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                                         Text(
//                                           timeago.format(timestamp),
//                                           style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Text(location, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Text(text, style: const TextStyle(fontSize: 16)),
//                               const SizedBox(height: 8),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       // Like Icon
//                                       InkWell(
//                                         onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (_) => LikesScreen(postId: readId),
//                                             ),
//                                           );
//                                         },
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.favorite,
//                                                 color: isLiked ? Colors.red : Colors.grey),
//                                             const SizedBox(width: 12),
//                                             Text('${likes.length}'),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(width: 16),
//                                       // Comment Icon
//                                       InkWell(
//                                         onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (_) => CommentScreen(postId: readId),
//                                             ),
//                                           );
//                                         },
//                                         child: Row(
//                                           children: [
//                                             const Icon(Icons.add_comment, color: Colors.grey),
//                                             const SizedBox(width: 12),
//                                             Text('${comments.length}'),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   PopupMenuButton<String>(
//                                     onSelected: (value) async {
//                                       if (value == 'copy') {
//                                         await Clipboard.setData(ClipboardData(text: text));
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           const SnackBar(content: Text("Copied to clipboard")),
//                                         );
//                                       } else if (value == 'share') {
//                                         await Share.share(text);
//                                       }
//                                     },
//                                     itemBuilder: (context) => const [
//                                       PopupMenuItem(value: 'copy', child: Text("Copy")),
//                                       PopupMenuItem(value: 'share', child: Text("Share")),
//                                     ],
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
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
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_buzz_app/screens/otherscreens/comment_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/likes_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  Stream<List<DocumentSnapshot>> getTrendingReadsStream() {
    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(hours: 48)),
    );

    return FirebaseFirestore.instance
        .collection('reads')
        .where('timestamp', isGreaterThan: cutoff)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Trending Reads")),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: getTrendingReadsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reads = snapshot.data!;

          return ListView.builder(
            itemCount: reads.length,
            itemBuilder: (context, index) {
              final read = reads[index];
              final data = read.data() as Map<String, dynamic>;
              final readId = read.id;
              final userId = data['uid'];
              final likes = (data['likes'] ?? []) as List;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final location = data['location'] ?? 'Unknown';
              final text = data['text'] ?? '';

              if (likes.length < 5) return const SizedBox(); // Filter by likes

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reads')
                    .doc(readId)
                    .collection('comments')
                    .snapshots(),
                builder: (context, commentSnapshot) {
                  if (!commentSnapshot.hasData) return const SizedBox();

                  final comments = commentSnapshot.data!.docs;

                  // Now count all comments (including author's)
                  if (comments.length < 2)
                    return const SizedBox(); // You can increase this number as needed

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                    builder: (context, userSnap) {
                      final userData =
                          userSnap.data?.data() as Map<String, dynamic>?;

                      final name = userData?['name'] ?? "Unknown";
                      final profilePic = userData?['profilePic'] ?? '';
                      final isLiked = likes.contains(currentUserId);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: profilePic.isNotEmpty
                                        ? NetworkImage(profilePic)
                                        : null,
                                    child: profilePic.isEmpty
                                        ? Text(name[0])
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(timestamp),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(text, style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // Toggle Like/Dislike
                                      GestureDetector(
                                        onTap: () async {
                                          final userId = FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid;
                                          final postRef = FirebaseFirestore
                                              .instance
                                              .collection('reads')
                                              .doc(readId);

                                          final postSnapshot = await postRef
                                              .get();
                                          final currentLikes =
                                              List<String>.from(
                                                postSnapshot['likes'] ?? [],
                                              );

                                          if (currentLikes.contains(userId)) {
                                            currentLikes.remove(userId);
                                          } else {
                                            currentLikes.add(userId);
                                          }

                                          await postRef.update({
                                            'likes': currentLikes,
                                          });
                                        },
                                        child: Icon(
                                          Icons.favorite,
                                          color: isLiked
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Open Likes Screen
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  LikesScreen(postId: readId),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          '${likes.length}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        //),
                                        //],
                                      ),
                                      const SizedBox(width: 16),
                                      // Comment Icon
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CommentScreen(postId: readId),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.comment,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 12),
                                            Text('${comments.length}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'copy') {
                                        await Clipboard.setData(
                                          ClipboardData(text: text),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Copied to clipboard",
                                            ),
                                          ),
                                        );
                                      } else if (value == 'share') {
                                        await Share.share(text);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'copy',
                                        child: Text("Copy"),
                                      ),
                                      PopupMenuItem(
                                        value: 'share',
                                        child: Text("Share"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
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
