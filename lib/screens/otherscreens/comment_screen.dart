// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class CommentScreen extends StatefulWidget {
//   final String postId;

//   const CommentScreen({super.key, required this.postId});

//   @override
//   State<CommentScreen> createState() => _CommentScreenState();
// }

// class _CommentScreenState extends State<CommentScreen> {
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   final TextEditingController commentController = TextEditingController();

//   // Future<void> addComment() async {
//   //   final text = commentController.text.trim();
//   //   if (text.isEmpty) return;

//   //   await FirebaseFirestore.instance
//   //       .collection('reads')
//   //       .doc(widget.postId)
//   //       .collection('comments')
//   //       .add({
//   //     'uid': currentUserId,
//   //     'text': text,
//   //     'timestamp': Timestamp.now(),
//   //   });

//   //   commentController.clear();
//   // }
//   Future<void> addComment() async {
//     final text = commentController.text.trim();

//     if (text.isEmpty) return;

//     try {
//       await FirebaseFirestore.instance
//           .collection('reads')
//           .doc(widget.postId)
//           .collection('comments')
//           .add({
//             'uid': currentUserId,
//             'text': commentController.text.trim(),
//             'timestamp': Timestamp.now(),
//           });

//       commentController.clear();
//       FocusScope.of(context).unfocus(); // dismiss keyboard

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Comment added')));
//     } catch (e) {
//       print("Error adding comment: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Comments")),
//       body: Column(
//         children: [
//           // Top Section: Post content
//           FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance
//                 .collection('reads')
//                 .doc(widget.postId)
//                 .get(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               }

//               final data = snapshot.data!.data() as Map<String, dynamic>;
//               final text = data['text'] ?? '';
//               final timestamp = data['timestamp']?.toDate();
//               final uid = data['uid'];

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(uid)
//                     .get(),
//                 builder: (context, userSnap) {
//                   if (!userSnap.hasData) return const SizedBox();

//                   final userData =
//                       userSnap.data!.data() as Map<String, dynamic>;
//                   final name = userData['name'] ?? 'User';

//                   return ListTile(
//                     title: Text(
//                       name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Text(text, style: const TextStyle(fontSize: 15)),
//                         const SizedBox(height: 4),
//                         if (timestamp != null)
//                           Text(
//                             timeago.format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           ),

//           const Divider(height: 1),

//           // Middle Section: Comment List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('reads')
//                   .doc(widget.postId)
//                   .collection('comments')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, commentSnap) {
//                 if (commentSnap.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!commentSnap.hasData || commentSnap.data!.docs.isEmpty) {
//                   return const Center(child: Text("No comments yet."));
//                 }

//                 final comments = commentSnap.data!.docs;

//                 return ListView.separated(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: comments.length,
//                   separatorBuilder: (_, __) => const Divider(),
//                   itemBuilder: (context, index) {
//                     final data = comments[index].data() as Map<String, dynamic>;
//                     final text = data['text'] ?? '';
//                     final timestamp = data['timestamp']?.toDate();
//                     final uid = data['uid'];

//                     return FutureBuilder<DocumentSnapshot>(
//                       future: FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(uid)
//                           .get(),
//                       builder: (context, userSnap) {
//                         if (!userSnap.hasData) return const SizedBox();

//                         final userData =
//                             userSnap.data!.data() as Map<String, dynamic>;
//                         final name = userData['name'] ?? 'User';

//                         return ListTile(
//                           title: Text(
//                             name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                             ),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 4),
//                               Text(text, style: const TextStyle(fontSize: 14)),
//                               const SizedBox(height: 4),
//                               if (timestamp != null)
//                                 Text(
//                                   timeago.format(timestamp),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           trailing: const Text(
//                             "Reply",
//                             style: TextStyle(color: Colors.blue, fontSize: 13),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // Bottom Section: Comment Input
//           Padding(
//             padding: const EdgeInsets.only(
//               left: 12,
//               right: 12,
//               bottom: 12,
//               top: 4,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: commentController,
//                     decoration: InputDecoration(
//                       hintText: "Write a comment...",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: addComment,
//                   color: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class CommentScreen extends StatefulWidget {
//   final String postId;
//   const CommentScreen({super.key, required this.postId});

//   @override
//   State<CommentScreen> createState() => _CommentScreenState();
// }

// class _CommentScreenState extends State<CommentScreen> {
//   final TextEditingController _commentController = TextEditingController();
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   //

//   Future<void> addComment() async {
//   final text = _commentController.text.trim();
//   if (text.isEmpty) return;

//   try {
//     // ➕ Add comment
//     await FirebaseFirestore.instance
//         .collection('reads')
//         .doc(widget.postId)
//         .collection('comments')
//         .add({
//       'uid': currentUserId,
//       'text': text,
//       'timestamp': Timestamp.now(),
//     });

//     // 📩 Send notification to post owner
//     final postDoc = await FirebaseFirestore.instance
//         .collection('reads')
//         .doc(widget.postId)
//         .get();

//     final postData = postDoc.data() as Map<String, dynamic>;
//     final postOwnerId = postData['uid'];
//     final postText = postData['text'] ?? '';

//     if (postOwnerId != currentUserId) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(postOwnerId)
//           .collection('notifications')
//           .add({
//         'type': 'comment',
//         'fromUserId': currentUserId,
//         'readId': widget.postId,
//         'text': 'commented on your read',
//         'postText': postText.length > 100
//             ? postText.substring(0, 100)
//             : postText,
//         'commentText': text.length > 100
//             ? text.substring(0, 100)
//             : text, 
//         'timestamp': Timestamp.now(),
//         'seen': false,
        
//       });
//     }

//     _commentController.clear();
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Failed to add comment')),
//     );
//   }
// }

//   Future<void> deleteComment(String commentId) async {
//     final postRef = FirebaseFirestore.instance
//         .collection('reads')
//         .doc(widget.postId);

//     try {
//       await postRef.collection('comments').doc(commentId).delete();

//       // 🟡 Important: Decrement comment count
//       await postRef.update({'commentCount': FieldValue.increment(-1)});
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to delete comment: $e")));
//     }
//   }


//   Future<void> editComment(String commentId, String oldText) async {
//     final controller = TextEditingController(text: oldText);

//     // Show edit dialog
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Edit Comment"),
//         content: TextField(
//           controller: controller,
//           maxLines: 3,
//           decoration: const InputDecoration(hintText: "Enter new comment"),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("Cancel"),
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//             },
//           ),
//           TextButton(
//             child: const Text("Update"),
//             onPressed: () async {
//               final newText = controller.text.trim();
//               if (newText.isNotEmpty) {
//                 try {
//                   await FirebaseFirestore.instance
//                       .collection('reads')
//                       .doc(widget.postId)
//                       .collection('comments')
//                       .doc(commentId)
//                       .update({'text': newText, 'timestamp': Timestamp.now()});

//                   Navigator.of(context).pop(); // Close on success
//                 } catch (e) {
//                   Navigator.of(context).pop(); // Still close
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Failed to update: $e")),
//                   );
//                 }
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Comment cannot be empty")),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentTile(String commentId, Map<String, dynamic> data) {
//     final uid = data['uid'];
//     final text = data['text'] ?? '';
//     final timestamp = data['timestamp']?.toDate();

//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
//       builder: (context, userSnap) {
//         if (!userSnap.hasData) return const SizedBox();

//         final userData = userSnap.data!.data() as Map<String, dynamic>;
//         final name = userData['name'] ?? 'User';
//         final isOwner = uid == currentUserId;

//         return ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               if (isOwner)
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'edit') {
//                       editComment(commentId, text);
//                     } else if (value == 'delete') {
//                       deleteComment(commentId);
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(value: 'edit', child: Text("Edit")),
//                     const PopupMenuItem(value: 'delete', child: Text("Delete")),
//                   ],
//                 ),
//             ],
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(text),
//               if (timestamp != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     timeago.format(timestamp),
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final postRef = FirebaseFirestore.instance
//         .collection('reads')
//         .doc(widget.postId);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Comments")),
//       body: Column(
//         children: [
//           // 🔹 Post Preview Section
//           FutureBuilder<DocumentSnapshot>(
//             future: postRef.get(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) return const SizedBox();

//               final postData = snapshot.data!.data() as Map<String, dynamic>;
//               final text = postData['text'] ?? '';
//               final timestamp = postData['timestamp']?.toDate();
//               final uid = postData['uid'];

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(uid)
//                     .get(),
//                 builder: (context, userSnap) {
//                   if (!userSnap.hasData) return const SizedBox();

//                   final user = userSnap.data!.data() as Map<String, dynamic>;
//                   final name = user['name'] ?? 'User';

//                   return Card(
//                     color: const Color.fromARGB(255, 118, 121, 124),
//                     margin: const EdgeInsets.all(12),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             name,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(text),
//                           const SizedBox(height: 4),
//                           if (timestamp != null)
//                             Text(
//                               timeago.format(timestamp),
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),

//           // 🔹 Divider with "Comments"
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Row(
//               children: const [
//                 Expanded(child: Divider(thickness: 1)),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     "Comments",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Expanded(child: Divider(thickness: 1)),
//               ],
//             ),
//           ),

//           // 🔹 Comment List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: postRef
//                   .collection('comments')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData)
//                   return const Center(child: CircularProgressIndicator());
//                 final docs = snapshot.data!.docs;

//                 if (docs.isEmpty) {
//                   return const Center(child: Text("No comments yet."));
//                 }

//                 return ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final comment = docs[index];
//                     final data = comment.data() as Map<String, dynamic>;
//                     return _buildCommentTile(comment.id, data);
//                   },
//                 );
//               },
//             ),
//           ),

//           // 🔹 Input Field
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _commentController,
//                     decoration: const InputDecoration(
//                       hintText: 'Add a comment...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(25)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.blue),
//                   onPressed: addComment,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;

// import 'package:local_buzz_app/screens/otherscreens/comments_provider.dart';

// class CommentScreen extends StatelessWidget {
//   final String postId;
//   const CommentScreen({super.key, required this.postId, });

//   @override
//   Widget build(BuildContext context) {
//     final postRef = FirebaseFirestore.instance.collection('reads').doc(postId);

//     return ChangeNotifierProvider(
//       create: (_) => CommentsProvider(postId),
//       child: Scaffold(
//         appBar: AppBar(title: const Text("Comments")),
//         body: Consumer<CommentsProvider>(
//           builder: (context, provider, _) => Column(
//             children: [
//               FutureBuilder<DocumentSnapshot>(
//                 future: postRef.get(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) return const SizedBox();
//                   final postData =
//                       snapshot.data!.data() as Map<String, dynamic>;
//                   final text = postData['text'] ?? '';
//                   final timestamp = postData['timestamp']?.toDate();
//                   final uid = postData['uid'];

//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(uid)
//                         .get(),
//                     builder: (context, userSnap) {
//                       if (!userSnap.hasData) return const SizedBox();
//                       final user =
//                           userSnap.data!.data() as Map<String, dynamic>;
//                       final name = user['name'] ?? 'User';

//                       return Card(
//                         color: const Color.fromARGB(255, 118, 121, 124),
//                         margin: const EdgeInsets.all(12),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(name,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold)),
//                               const SizedBox(height: 4),
//                               Text(text),
//                               const SizedBox(height: 4),
//                               if (timestamp != null)
//                                 Text(
//                                   timeago.format(timestamp),
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Colors.grey),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),

//               // Divider
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 child: Row(
//                   children: [
//                     Expanded(child: Divider(thickness: 1)),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8),
//                       child: Text(
//                         "Comments",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Expanded(child: Divider(thickness: 1)),
//                   ],
//                 ),
//               ),

//               // Comments List
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: provider.commentStream,
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     final docs = snapshot.data!.docs;
//                     if (docs.isEmpty) {
//                       return const Center(child: Text("No comments yet."));
//                     }

//                     return ListView.builder(
//                       itemCount: docs.length,
//                       itemBuilder: (context, index) {
//                         final comment = docs[index];
//                         final data =
//                             comment.data() as Map<String, dynamic>;
//                         final uid = data['uid'];
//                         final text = data['text'] ?? '';
//                         final timestamp = data['timestamp']?.toDate();
//                         final isOwner = uid ==
//                             FirebaseAuth.instance.currentUser!.uid;

//                         return FutureBuilder<DocumentSnapshot>(
//                           future: FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(uid)
//                               .get(),
//                           builder: (context, userSnap) {
//                             if (!userSnap.hasData) return const SizedBox();
//                             final userData = userSnap.data!.data()
//                                 as Map<String, dynamic>;
//                             final name = userData['name'] ?? 'User';

//                             return ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16),
//                               title: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(name,
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   if (isOwner)
//                                     PopupMenuButton<String>(
//                                       onSelected: (value) {
//                                         if (value == 'edit') {
//                                           provider.editComment(
//                                               context, comment.id, text);
//                                         } else if (value == 'delete') {
//                                           provider.deleteComment(
//                                               context, comment.id);
//                                         }
//                                       },
//                                       itemBuilder: (context) => [
//                                         const PopupMenuItem(
//                                             value: 'edit', child: Text("Edit")),
//                                         const PopupMenuItem(
//                                             value: 'delete',
//                                             child: Text("Delete")),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(text),
//                                   if (timestamp != null)
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 4),
//                                       child: Text(
//                                         timeago.format(timestamp),
//                                         style: const TextStyle(
//                                             fontSize: 12, color: Colors.grey),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),

//               // Input
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: provider.commentController,
//                         decoration: const InputDecoration(
//                           hintText: 'Add a comment...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(25),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.send, color: Colors.blue),
//                       onPressed: () => provider.addComment(context),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:timeago/timeago.dart' as timeago;

// import 'package:local_buzz_app/screens/otherscreens/comments_provider.dart';

// class CommentScreen extends StatelessWidget {
//   final String postId;
//   const CommentScreen({super.key, required this.postId});

//   @override
//   Widget build(BuildContext context) {
//     final postRef = FirebaseFirestore.instance.collection('reads').doc(postId);

//     return ChangeNotifierProvider(
//       create: (_) => CommentsProvider(postId),
//       child: Scaffold(
//         appBar: AppBar(title: const Text("Comments")),
//         body: Consumer<CommentsProvider>(
//           builder: (context, provider, _) => Column(
//             children: [
//               FutureBuilder<DocumentSnapshot>(
//                 future: postRef.get(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) return const SizedBox();
//                   final postData = snapshot.data!.data() as Map<String, dynamic>;
//                   final text = postData['text'] ?? '';
//                   final timestamp = postData['timestamp']?.toDate();
//                   final authorId = postData['uid'];

//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance.collection('users').doc(authorId).get(),
//                     builder: (context, userSnap) {
//                       if (!userSnap.hasData) return const SizedBox();
//                       final user = userSnap.data!.data() as Map<String, dynamic>;
//                       final name = user['name'] ?? 'User';

//                       return Card(
//                         color: const Color.fromARGB(255, 118, 121, 124),
//                         margin: const EdgeInsets.all(12),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                               const SizedBox(height: 4),
//                               Text(text),
//                               const SizedBox(height: 4),
//                               if (timestamp != null)
//                                 Text(
//                                   timeago.format(timestamp),
//                                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),

//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 child: Row(
//                   children: [
//                     Expanded(child: Divider(thickness: 1)),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8),
//                       child: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Expanded(child: Divider(thickness: 1)),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: provider.commentStream,
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     final docs = snapshot.data!.docs;
//                     if (docs.isEmpty) {
//                       return const Center(child: Text("No comments yet."));
//                     }

//                     return ListView.builder(
//                       itemCount: docs.length,
//                       itemBuilder: (context, index) {
//                         final comment = docs[index];
//                         final data = comment.data() as Map<String, dynamic>;
//                         final uid = data['uid'];
//                         final text = data['text'] ?? '';
//                         final timestamp = data['timestamp']?.toDate();

//                         return FutureBuilder<DocumentSnapshot>(
//                           future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
//                           builder: (context, userSnap) {
//                             if (!userSnap.hasData) return const SizedBox();
//                             final userData = userSnap.data!.data() as Map<String, dynamic>;
//                             final name = userData['name'] ?? 'User';

//                             final isOwner = uid == FirebaseAuth.instance.currentUser!.uid;
//                             final isAuthor = uid == (snapshot.data!.docs.first['uid']); // comment vs post author

//                             return ListTile(
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                               title: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                                       if (isAuthor)
//                                         Container(
//                                           margin: const EdgeInsets.only(left: 6),
//                                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                           decoration: BoxDecoration(
//                                             color: Colors.orange.shade100,
//                                             borderRadius: BorderRadius.circular(4),
//                                           ),
//                                           child: const Text(
//                                             "Author",
//                                             style: TextStyle(
//                                               color: Colors.orange,
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                   if (isOwner)
//                                     PopupMenuButton<String>(
//                                       onSelected: (value) {
//                                         if (value == 'edit') {
//                                           provider.editComment(context, comment.id, text);
//                                         } else if (value == 'delete') {
//                                           provider.deleteComment(context, comment.id);
//                                         }
//                                       },
//                                       itemBuilder: (context) => [
//                                         const PopupMenuItem(value: 'edit', child: Text("Edit")),
//                                         const PopupMenuItem(value: 'delete', child: Text("Delete")),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(text),
//                                   if (timestamp != null)
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 4),
//                                       child: Text(
//                                         timeago.format(timestamp),
//                                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: provider.commentController,
//                         decoration: const InputDecoration(
//                           hintText: 'Add a comment...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(25)),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.send, color: Colors.blue),
//                       onPressed: () => provider.addComment(context),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:local_buzz_app/screens/otherscreens/comments_provider.dart';

class CommentScreen extends StatelessWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final postRef = FirebaseFirestore.instance.collection('reads').doc(postId);

    return ChangeNotifierProvider(
      create: (_) => CommentsProvider(postId),
      child: Scaffold(
        appBar: AppBar(title: const Text("Comments")),
        body: Consumer<CommentsProvider>(
          builder: (context, provider, _) => FutureBuilder<DocumentSnapshot>(
            future: postRef.get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final postData = snapshot.data!.data() as Map<String, dynamic>;
              final text = postData['text'] ?? '';
              final timestamp = postData['timestamp']?.toDate();
              final authorId = postData['uid'];

              return Column(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(authorId).get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const SizedBox();
                      final user = userSnap.data!.data() as Map<String, dynamic>;
                      final name = user['name'] ?? 'User';

                      return Card(
                        color: const Color.fromARGB(255, 236, 237, 238),
                        margin: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(text),
                              const SizedBox(height: 4),
                              if (timestamp != null)
                                Text(
                                  timeago.format(timestamp),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: provider.commentStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(child: Text("No comments yet."));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final comment = docs[index];
                            final data = comment.data() as Map<String, dynamic>;
                            final uid = data['uid'];
                            final text = data['text'] ?? '';
                            final timestamp = data['timestamp']?.toDate();

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                              builder: (context, userSnap) {
                                if (!userSnap.hasData) return const SizedBox();
                                final userData = userSnap.data!.data() as Map<String, dynamic>;
                                final name = userData['name'] ?? 'User';

                                final isOwner = uid == FirebaseAuth.instance.currentUser!.uid;
                                final isAuthor = uid == authorId; // ✅ Correctly compare with post author ID

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          if (isAuthor)
                                            Container(
                                              margin: const EdgeInsets.only(left: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                "Author",
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (isOwner)
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              provider.editComment(context, comment.id, text);
                                            } else if (value == 'delete') {
                                              provider.deleteComment(context, comment.id);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'edit', child: Text("Edit")),
                                            const PopupMenuItem(value: 'delete', child: Text("Delete")),
                                          ],
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(text),
                                      if (timestamp != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            timeago.format(timestamp),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: provider.commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: () => provider.addComment(context),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}