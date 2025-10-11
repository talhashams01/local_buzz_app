

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