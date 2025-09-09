// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsScreen extends StatelessWidget {
//    NotificationsScreen({Key? key}) : super(key: key);
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     final notiRef = FirebaseFirestore.instance
//         .collection('notifications')
//         .doc(currentUserId)
//         .collection('userNotifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notiRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) return const Center(child: Text("No notifications yet."));

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final type = data['type'] ?? '';
//               final fromUid = data['fromUid'];
//               final timestamp = data['timestamp']?.toDate();
//               final postId = data['postId'];

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('users').doc(fromUid).get(),
//                 builder: (context, userSnap) {
//                   if (!userSnap.hasData) return const SizedBox();

//                   final user = userSnap.data!.data() as Map<String, dynamic>;
//                   final name = user['name'] ?? 'Someone';

//                   String message = '';
//                   if (type == 'like') {
//                     message = "$name liked your read";
//                   } else if (type == 'comment') {
//                     message = "$name commented on your read";
//                   }

//                   return ListTile(
//                     title: Text(message),
//                     subtitle: timestamp != null
//                         ? Text(timeago.format(timestamp),
//                             style: const TextStyle(color: Colors.grey))
//                         : null,
//                     onTap: () {
//                       // Optional: Navigate to Read Detail screen if you want
//                       // Navigator.push(context, MaterialPageRoute(builder: (_) => ReadDetailScreen(postId: postId)));
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
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsTab extends StatelessWidget {
//    NotificationsTab({Key? key}) : super(key: key);
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Notifications")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(child: Text("No notifications yet."));
//           }

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final fromUserId = data['fromUserId'];
//               final text = data['text'];
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final preview = data['preview'] ?? '';
//               final seen = data['seen'] ?? false;

//               return ListTile(
//                 tileColor: seen ? Colors.white : Colors.grey.shade200,
//                 title: Text("Someone $text"),
//                 subtitle: Text(
//                   "$preview\n${timeago.format(timestamp)}",
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 isThreeLine: true,
//                 onTap: () {
//                   // Mark as seen (optional)
//                   FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(currentUserId)
//                       .collection('notifications')
//                       .doc(docs[index].id)
//                       .update({'seen': true});
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
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsTab extends StatelessWidget {
//   NotificationsTab({Key? key}) : super(key: key);
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Notifications")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(child: Text("No notifications yet."));
//           }

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final fromUserId = data['fromUserId'];
//               final text = data['text'];
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final preview = data['preview'] ?? '';
//               final seen = data['seen'] ?? false;

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//                 builder: (context, userSnapshot) {
//                   if (!userSnapshot.hasData) return const SizedBox();

//                   final userData = userSnapshot.data!.data() as Map<String, dynamic>;
//                   final username = userData['name'] ?? 'User';

//                   return ListTile(
//                     tileColor: seen ? const Color.fromARGB(255, 95, 92, 92) : const Color.fromARGB(255, 141, 130, 130), // light grey for unread
//                     leading: CircleAvatar(
//                       backgroundColor: const Color.fromARGB(255, 96, 122, 134),
//                       child: Text(username[0].toUpperCase()),
//                     ),
//                     title: Text(
//                       "$username $text",
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (preview.isNotEmpty)
//                           Text(
//                             preview,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         Row(mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               timeago.format(timestamp),
//                               style: const TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       // Mark as seen
//                       FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(currentUserId)
//                           .collection('notifications')
//                           .doc(docs[index].id)
//                           .update({'seen': true});
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
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsTab extends StatelessWidget {
//   NotificationsTab({Key? key}) : super(key: key);
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         foregroundColor: isDark ? Colors.white : Colors.black,
//         elevation: 0,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return Center(
//               child: Text(
//                 "No notifications yet.",
//                 style: TextStyle(
//                   color: isDark ? Colors.white : Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//             );
//           }

//           return ListView.separated(
//             itemCount: docs.length,
//             separatorBuilder: (context, index) => Divider(
//               color: Colors.grey,
//               thickness: 1,
//             ),
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final fromUserId = data['fromUserId'];
//               final text = data['text'];
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final preview = data['preview'] ?? '';
//               final seen = data['seen'] ?? false;

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//                 builder: (context, userSnapshot) {
//                   if (!userSnapshot.hasData) return const SizedBox();

//                   final userData = userSnapshot.data!.data() as Map<String, dynamic>;
//                   final username = userData['name'] ?? 'User';

//                   return Container(
//                     color: isDark
//                         ? (seen ? Colors.black : const Color.fromARGB(255, 5, 5, 5))
//                         : (seen ? Colors.white : const Color(0xFFF5F5F5)),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: Colors.blueGrey,
//                           child: Text(username[0].toUpperCase(),
//                               style: const TextStyle(color: Colors.white)),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "$username $text",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: isDark ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                               if (preview.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 4.0),
//                                   child: Text(
//                                     preview,
//                                     style: TextStyle(
//                                       color: isDark ? Colors.white : Colors.black87,
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 6),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       timeago.format(timestamp),
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
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
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsTab extends StatelessWidget {
//   NotificationsTab({Key? key}) : super(key: key);
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(child: Text("No notifications yet."));
//           }

//           return ListView.separated(
//             itemCount: docs.length,
//             separatorBuilder: (context, index) => Divider(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.grey.shade800
//                   : Colors.grey.shade300,
//               thickness: 0.5,
//               height: 0,
//             ),
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final fromUserId = data['fromUserId'];
//               final text = data['text'];
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final preview = data['preview'] ?? '';
//               final seen = data['seen'] ?? false;

//               // return FutureBuilder<DocumentSnapshot>(
//               //   future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//               //   builder: (context, userSnap) {
//               //     if (!userSnap.hasData) return const SizedBox();

//               //     final userData = userSnap.data!.data() as Map<String, dynamic>;
//               //     final username = userData['name'] ?? 'Someone';

//               //     final textColor = Theme.of(context).brightness == Brightness.dark
//               //         ? Colors.white
//               //         : Colors.black;
//               //     final subtitleColor = Theme.of(context).brightness == Brightness.dark
//               //         ? Colors.white70
//               //         : Colors.black54;
//               //     final timeColor = Theme.of(context).brightness == Brightness.dark
//               //         ? Colors.grey
//               //         : Colors.grey.shade700;

//               //     return ListTile(
//               //       tileColor: seen
//               //           ? Theme.of(context).scaffoldBackgroundColor
//               //           : Theme.of(context).brightness == Brightness.dark
//               //               ? Colors.grey.shade900
//               //               : Colors.grey.shade100,
//               //       leading: CircleAvatar(
//               //         backgroundColor: Colors.blueGrey,
//               //         child: Text(
//               //           username.isNotEmpty ? username[0].toUpperCase() : '?',
//               //           style: const TextStyle(color: Colors.white),
//               //         ),
//               //       ),
//               //       title: Text(
//               //         "$username $text",
//               //         style: TextStyle(
//               //           fontWeight: FontWeight.bold,
//               //           color: textColor,
//               //         ),
//               //       ),
//               //       subtitle: Column(
//               //         crossAxisAlignment: CrossAxisAlignment.start,
//               //         children: [
//               //           Text(
//               //             preview,
//               //             style: TextStyle(color: subtitleColor),
//               //           ),
//               //           const SizedBox(height: 4),
//               //           Text(
//               //             timeago.format(timestamp),
//               //             style: TextStyle(fontSize: 12, color: timeColor),
//               //           ),
//               //         ],
//               //       ),
//               //       isThreeLine: true,
//               //       onTap: () {
//               //         FirebaseFirestore.instance
//               //             .collection('users')
//               //             .doc(currentUserId)
//               //             .collection('notifications')
//               //             .doc(docs[index].id)
//               //             .update({'seen': true});
//               //       },
//               //     );
//               //   },
//               // );

// return FutureBuilder<DocumentSnapshot>(
//   future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//   builder: (context, userSnap) {
//     if (!userSnap.hasData) return const SizedBox();

//     final userData = userSnap.data!.data() as Map<String, dynamic>;
//     final username = userData['name'] ?? 'Someone';

//     final textColor = Theme.of(context).brightness == Brightness.dark
//         ? Colors.white
//         : Colors.black;
//     final subtitleColor = Theme.of(context).brightness == Brightness.dark
//         ? Colors.white70
//         : Colors.black54;
//     final timeColor = Theme.of(context).brightness == Brightness.dark
//         ? Colors.grey
//         : Colors.grey.shade700;

//     final commentText = data['commentText'] ?? '';
//     final postText = data['postText'] ?? '';
//     final type = data['type'];

//     return ListTile(
//       tileColor: seen
//           ? Theme.of(context).scaffoldBackgroundColor
//           : Theme.of(context).brightness == Brightness.dark
//               ? Colors.grey.shade900
//               : Colors.grey.shade100,
//       leading: CircleAvatar(
//         backgroundColor: Colors.blueGrey,
//         child: Text(
//           username.isNotEmpty ? username[0].toUpperCase() : '?',
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),
//       title: Text(
//         "$username $text",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (type == 'comment') ...[
//             Text(
//               'Comment: $commentText',
//               style: TextStyle(color: subtitleColor),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'On: "$postText"',
//               style: TextStyle(
//                 color: subtitleColor.withOpacity(0.9),
//                 fontStyle: FontStyle.italic,
//                 fontSize: 13,
//               ),
//             ),
//           ] else ...[
//             Text(
//               postText,
//               style: TextStyle(color: subtitleColor),
//             ),
//           ],
//           const SizedBox(height: 4),
//           Text(
//             timeago.format(timestamp),
//             style: TextStyle(fontSize: 12, color: timeColor),
//           ),
//         ],
//       ),
//       isThreeLine: true,
//       onTap: () {
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUserId)
//             .collection('notifications')
//             .doc(docs[index].id)
//             .update({'seen': true});
//       },
//     );
//   },
// );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsTab extends StatefulWidget {
//   const NotificationsTab({Key? key}) : super(key: key);

//   @override
//   State<NotificationsTab> createState() => _NotificationsTabState();
// }

// class _NotificationsTabState extends State<NotificationsTab> {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Automatically mark all notifications as seen when the
//     markAllAsSeen(); // 🔥 Automatically mark as seen
//   });
//     }

//   // Future<void> markAllAsSeen() async {
//   //   final snapshot = await FirebaseFirestore.instance
//   //       .collection('users')
//   //       .doc(currentUserId)
//   //       .collection('notifications')
//   //       .where('seen', isEqualTo: false)
//   //       .get();

//   //   for (final doc in snapshot.docs) {
//   //     doc.reference.update({'seen': true});
//   //   }
//   // }
//   Future<void> markAllAsSeen() async {
//   final query = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(currentUserId)
//       .collection('notifications')
//       .where('seen', isEqualTo: false)
//       .get();

//   final batch = FirebaseFirestore.instance.batch();

//   for (final doc in query.docs) {
//     batch.update(doc.reference, {'seen': true});
//   }

//   await batch.commit(); // ✅ Faster atomic update
// }

//   @override
// Widget build(BuildContext context) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   final textColor = isDark ? Colors.white : Colors.black;
//   final subtitleColor = isDark ? Colors.white70 : Colors.black54;
//   final timeColor = isDark ? Colors.grey : Colors.grey.shade700;

//   final notificationsRef = FirebaseFirestore.instance
//       .collection('users')
//       .doc(currentUserId)
//       .collection('notifications')
//       .orderBy('timestamp', descending: true);

//   return Scaffold(
//     backgroundColor: Colors.black, // pure black
//     appBar: AppBar(
//       title: const Text("Notifications"),
//       backgroundColor: Colors.black,
//     ),
//     body: StreamBuilder<QuerySnapshot>(
//       stream: notificationsRef.snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//         final docs = snapshot.data!.docs;
//         if (docs.isEmpty) return const Center(child: Text("No notifications yet", style: TextStyle(color: Colors.white)));

//         return ListView.separated(
//           itemCount: docs.length,
//           separatorBuilder: (context, index) => Divider(
//             color: Colors.grey.shade800,
//             height: 1,
//           ),
//           itemBuilder: (context, index) {
//             final data = docs[index].data() as Map<String, dynamic>;
//             final fromUserId = data['fromUserId'];
//             final text = data['text'] ?? '';
//             final postText = data['postText'] ?? '';
//             final commentText = data['commentText'] ?? '';
//             final timestamp = (data['timestamp'] as Timestamp).toDate();

//             return FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//               builder: (context, userSnap) {
//                 if (!userSnap.hasData) return const SizedBox();

//                 final userData = userSnap.data!.data() as Map<String, dynamic>;
//                 final username = userData['name'] ?? 'Someone';

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Avatar
//                       CircleAvatar(
//                         backgroundColor: Colors.blueGrey,
//                         child: Text(
//                           username[0].toUpperCase(),
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       // Text
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "$username $text",
//                               style: TextStyle(
//                                 color: textColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             if (data['type'] == 'comment') ...[
//                               Text("Read: $postText", style: TextStyle(color: subtitleColor)),
//                               const SizedBox(height: 2),
//                               Text("Comment: $commentText", style: TextStyle(color: subtitleColor)),
//                             ] else ...[
//                               Text(postText, style: TextStyle(color: subtitleColor)),
//                             ],
//                             const SizedBox(height: 6),
//                             Text(
//                               timeago.format(timestamp),
//                               style: TextStyle(fontSize: 12, color: timeColor),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     ),
//   );
// }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsTab extends StatefulWidget {
//   const NotificationsTab({Key? key}) : super(key: key);

//   @override
//   State<NotificationsTab> createState() => _NotificationsTabState();
// }

// class _NotificationsTabState extends State<NotificationsTab> {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<NotificationSeenProvider>(context, listen: false).markAllAsSeen(); // 🔥 Auto mark as seen on open
//     });
//   }

//   Future<void> markAllAsSeen() async {
//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (final doc in query.docs) {
//       batch.update(doc.reference, {'seen': true});
//     }
//     await batch.commit();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black;
//     final subtitleColor = isDark ? Colors.white70 : Colors.black54;
//     final timeColor = isDark ? Colors.grey : Colors.grey.shade700;

//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: Colors.black,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(
//               child: Text("No notifications yet", style: TextStyle(color: Colors.white)),
//             );
//           }

//           return ListView.separated(
//             itemCount: docs.length,
//             separatorBuilder: (context, index) => Divider(
//               color: Colors.grey.shade800,
//               height: 1,
//             ),
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final fromUserId = data['fromUserId'];
//               final text = data['text'] ?? '';
//               final postText = data['postText'] ?? '';
//               final commentText = data['commentText'] ?? '';
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final type = data['type'] ?? 'like';

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//                 builder: (context, userSnap) {
//                   if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox();

//                   final userData = userSnap.data!.data() as Map<String, dynamic>;
//                   final username = userData['name'] ?? 'Someone';

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 🔵 Circle Avatar
//                         CircleAvatar(
//                           backgroundColor: Colors.blueGrey,
//                           child: Text(
//                             username.isNotEmpty ? username[0].toUpperCase() : '?',
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         // 🔤 Notification text
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "$username $text",
//                                 style: TextStyle(
//                                   color: textColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               if (type == 'comment') ...[
//                                 Text("Read: $postText", style: TextStyle(color: subtitleColor)),
//                                 const SizedBox(height: 2),
//                                 Text("Comment: $commentText", style: TextStyle(color: subtitleColor)),
//                               ] else ...[
//                                 Text(postText, style: TextStyle(color: subtitleColor)),
//                               ],
//                               const SizedBox(height: 6),
//                               Text(
//                                 timeago.format(timestamp),
//                                 style: TextStyle(fontSize: 12, color: timeColor),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// //import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
// //import 'package:provider/provider.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsTab extends StatefulWidget {
//   const NotificationsTab({Key? key}) : super(key: key);

//   @override
//   State<NotificationsTab> createState() => _NotificationsTabState();
// }

// class _NotificationsTabState extends State<NotificationsTab> {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black;
//     final subtitleColor = isDark ? Colors.white70 : Colors.black54;
//     final timeColor = isDark ? Colors.grey : Colors.grey.shade700;

//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: Colors.black,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(
//               child: Text("No notifications yet", style: TextStyle(color: Colors.white)),
//             );
//           }

//           return ListView.separated(
//             itemCount: docs.length,
//             separatorBuilder: (context, index) => Divider(
//               color: Colors.grey.shade800,
//               height: 1,
//             ),
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final fromUserId = data['fromUserId'];
//               final text = data['text'] ?? '';
//               final postText = data['postText'] ?? '';
//               final commentText = data['commentText'] ?? '';
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final type = data['type'] ?? 'like';

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//                 builder: (context, userSnap) {
//                   if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox();

//                   final userData = userSnap.data!.data() as Map<String, dynamic>;
//                   final username = userData['name'] ?? 'Someone';

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: Colors.blueGrey,
//                           child: Text(
//                             username.isNotEmpty ? username[0].toUpperCase() : '?',
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "$username $text",
//                                 style: TextStyle(
//                                   color: textColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               if (type == 'comment') ...[
//                                 Text("Read: $postText", style: TextStyle(color: subtitleColor)),
//                                 const SizedBox(height: 2),
//                                 Text("Comment: $commentText", style: TextStyle(color: subtitleColor)),
//                               ] else ...[
//                                 Text(postText, style: TextStyle(color: subtitleColor)),
//                               ],
//                               const SizedBox(height: 6),
//                               Text(
//                                 timeago.format(timestamp),
//                                 style: TextStyle(fontSize: 12, color: timeColor),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeago;
// //import 'package:intl/intl.dart';

// class NotificationsTab extends StatefulWidget {
//   const NotificationsTab({Key? key}) : super(key: key);

//   @override
//   State<NotificationsTab> createState() => _NotificationsTabState();
// }

// class _NotificationsTabState extends State<NotificationsTab> {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void initState() {
//     super.initState();
//     // Auto mark all as seen
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       markAllAsSeen();
//     });
//   }

//   Future<void> markAllAsSeen() async {
//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (final doc in query.docs) {
//       batch.update(doc.reference, {'seen': true});
//     }
//     await batch.commit();
//   }

//   String getLabel(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final thisWeek = today.subtract(const Duration(days: 7));

//     if (date.isAfter(today)) return "Today";
//     if (date.isAfter(yesterday)) return "Yesterday";
//     if (date.isAfter(thisWeek)) return "This Week";
//     return "Earlier";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black;
//     final subtitleColor = isDark ? Colors.white70 : Colors.black54;
//     final timeColor = isDark ? Colors.grey : Colors.grey.shade700;

//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: Colors.black,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) {
//             return const Center(
//               child: Text("No notifications yet", style: TextStyle(color: Colors.white)),
//             );
//           }

//           Map<String, List<QueryDocumentSnapshot>> grouped = {};
//           for (var doc in docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             final timestamp = (data['timestamp'] as Timestamp).toDate();
//             final label = getLabel(timestamp);
//             grouped.putIfAbsent(label, () => []).add(doc);
//           }

//           final labels = ['Today', 'Yesterday', 'This Week', 'Earlier'];

//           return ListView(
//             children: labels.where((l) => grouped[l] != null).expand((label) {
//               return [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 ...grouped[label]!.map((doc) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final fromUserId = data['fromUserId'];
//                   final text = data['text'] ?? '';
//                   final postText = data['postText'] ?? '';
//                   final commentText = data['commentText'] ?? '';
//                   final timestamp = (data['timestamp'] as Timestamp).toDate();
//                   final type = data['type'] ?? 'like';

//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
//                     builder: (context, userSnap) {
//                       if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox();

//                       final userData = userSnap.data!.data() as Map<String, dynamic>;
//                       final username = userData['name'] ?? 'Someone';

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Colors.blueGrey,
//                               child: Text(
//                                 username.isNotEmpty ? username[0].toUpperCase() : '?',
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "$username $text",
//                                     style: TextStyle(
//                                       color: textColor,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   if (type == 'comment') ...[
//                                     Text("Read: $postText", style: TextStyle(color: subtitleColor)),
//                                     const SizedBox(height: 2),
//                                     Text("Comment: $commentText", style: TextStyle(color: subtitleColor)),
//                                   ] else ...[
//                                     Text(postText, style: TextStyle(color: subtitleColor)),
//                                   ],
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     timeago.format(timestamp),
//                                     style: TextStyle(fontSize: 12, color: timeColor),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 }).toList()
//               ];
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }

// comments and likes work with red dot(perfecr code)

//lib/screens/notification_screen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
// import 'package:provider/provider.dart';
// //import 'package:provider/provider.dart';
// import 'package:timeago/timeago.dart' as timeago;

// //import 'otherscreens/notification_seen_provider.dart';
// class NotificationsTab extends StatefulWidget {
//   const NotificationsTab({super.key});

//   @override
//   State<NotificationsTab> createState() => _NotificationsTabState();
// }

// class _NotificationsTabState extends State<NotificationsTab> {
//   @override
//   void initState() {
//     super.initState();
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     // Mark notifications as seen only after UI is built
//     Future.delayed(Duration(milliseconds: 500));
//     () {
//       Provider.of<NotificationSeenProvider>(
//         context,
//         listen: false,
//       ).markAllAsSeen();
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//     final notificationsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('notifications')
//         .orderBy('timestamp', descending: true);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: Colors.black,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: notificationsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData)
//             return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No notifications yet",
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }

//           final Map<String, List<QueryDocumentSnapshot>> grouped = {};
//           for (var doc in docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             final timestamp = (data['timestamp'] as Timestamp).toDate();
//             final label = _getLabel(timestamp);
//             grouped.putIfAbsent(label, () => []).add(doc);
//           }

//           final labels = ['Today', 'Yesterday', 'This Week', 'Earlier'];

//           return ListView(
//             children: labels.where((l) => grouped[l] != null).expand((label) {
//               return [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 10,
//                   ),
//                   child: Text(
//                     label,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),

                            
//                 ...grouped[label]!.map((doc) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final fromUserId = data['fromUserId'] ?? 'unknown';
//                   final text = data['text'] ?? '';
//                   final postText = data['postText'] ?? '';
//                   final commentText = data['commentText'] ?? '';
//                   final timestamp = (data['timestamp'] as Timestamp).toDate();
//                   final type = data['type']?.toString() ?? 'unknown';

//                   print('🔔 Notification type: $type');
//                   print('🔔 Notification data: $data');

//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(fromUserId)
//                         .get(),
//                     builder: (context, userSnap) {
//                       if (!userSnap.hasData || !userSnap.data!.exists)
//                         return const SizedBox();
//                       final userData =
//                           userSnap.data!.data() as Map<String, dynamic>;
//                       final username = userData['name'] ?? 'Someone';

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Colors.blueGrey,
//                               child: Text(
//                                 username.isNotEmpty
//                                     ? username[0].toUpperCase()
//                                     : '?',
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "$username $text",
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   if (type == 'comment') ...[
//                                     Text(
//                                       "Read: $postText",
//                                       style: const TextStyle(
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       "Comment: $commentText",
//                                       style: const TextStyle(
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                   ] else if (type == 'like') ...[
//                                     Text(
//                                       "Read: $postText",
//                                       style: const TextStyle(
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                   ] else ...[
//                                     Text(
//                                       "(Unknown notification)",
//                                       style: const TextStyle(
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     timeago.format(timestamp),
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 }).toList(),
//               ];
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }

//   String _getLabel(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final thisWeek = today.subtract(const Duration(days: 7));

//     if (date.isAfter(today)) return "Today";
//     if (date.isAfter(yesterday)) return "Yesterday";
//     if (date.isAfter(thisWeek)) return "This Week";
//     return "Earlier";
//   }
// }



//same code as above only 1 thing changed is light dark mode support

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500));
    () {
      Provider.of<NotificationSeenProvider>(
        context,
        listen: false,
      ).markAllAsSeen();
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            );
          }

          final Map<String, List<QueryDocumentSnapshot>> grouped = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final label = _getLabel(timestamp);
            grouped.putIfAbsent(label, () => []).add(doc);
          }

          final labels = ['Today', 'Yesterday', 'This Week', 'Earlier'];

          return ListView(
            children: labels.where((l) => grouped[l] != null).expand((label) {
              return [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...grouped[label]!.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fromUserId = data['fromUserId'] ?? 'unknown';
                  final text = data['text'] ?? '';
                  final postText = data['postText'] ?? '';
                  final commentText = data['commentText'] ?? '';
                  final timestamp = (data['timestamp'] as Timestamp).toDate();
                  final type = data['type']?.toString() ?? 'unknown';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(fromUserId)
                        .get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData || !userSnap.data!.exists)
                        return const SizedBox();
                      final userData = userSnap.data!.data() as Map<String, dynamic>;
                      final username = userData['name'] ?? 'Someone';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.onPrimaryContainer,
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$username $text",
                                    style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (type == 'comment') ...[
                                    Text(
                                      "Read: $postText",
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Comment: $commentText",
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                  ] else if (type == 'like') ...[
                                    Text(
                                      "Read: $postText",
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      "(Unknown notification)",
                                      style: TextStyle(
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    timeago.format(timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ];
            }).toList(),
          );
        },
      ),
    );
  }

  String _getLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    if (date.isAfter(today)) return "Today";
    if (date.isAfter(yesterday)) return "Yesterday";
    if (date.isAfter(thisWeek)) return "This Week";
    return "Earlier";
  }
}


