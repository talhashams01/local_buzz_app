

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
