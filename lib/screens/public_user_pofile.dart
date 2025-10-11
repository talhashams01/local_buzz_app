



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:local_buzz_app/screens/otherscreens/comment_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/likes_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class PublicProfileScreen extends StatelessWidget {
  final String userId;
  const PublicProfileScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '';
          final username = data['username'] ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('@$username', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Posts", style: TextStyle(fontWeight: FontWeight.bold)),
                        _PostCount(userId: userId),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(child: _UserPosts(userId: userId)),
            ],
          );
        },
      ),
    );
  }
}

class _PostCount extends StatelessWidget {
  final String userId;
  const _PostCount({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reads')
          .where('uid', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text("...");
        return Text(snapshot.data!.docs.length.toString());
      },
    );
  }
}

class _UserPosts extends StatelessWidget {
  final String userId;
  const _UserPosts({required this.userId});

  void _toggleLike(String postId, List likes, BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final postRef = FirebaseFirestore.instance.collection('reads').doc(postId);
    final isLiked = likes.contains(currentUserId);

    await postRef.update({
      'likes': isLiked
          ? FieldValue.arrayRemove([currentUserId])
          : FieldValue.arrayUnion([currentUserId])
    });

    Provider.of<LikeNotifier>(context, listen: false).notify(); // ✅ Notify rebuild
  }

  void _showOptions(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text("Copy Text"),
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Text copied")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share"),
              onTap: () {
                Navigator.pop(context);
                Share.share(text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Consumer<LikeNotifier>(
      builder: (context, _, __) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reads')
              .where('uid', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;

            if (docs.isEmpty) return const Center(child: Text("No posts yet."));

            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final postId = doc.id;
                final text = data['text'] ?? '';
                final location = data['location'] ?? '';
                final timestamp = data['timestamp']?.toDate();
                final List likes = data['likes'] ?? [];
                final isLiked = likes.contains(currentUserId);

                return GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Text copied")),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              Row(
                                children: [
                                  if (timestamp != null)
                                    Text(
                                      timeago.format(timestamp),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    onPressed: () => _showOptions(context, text),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(text, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      size: 18,
                                      color: isLiked ? Colors.red : Colors.grey.shade600,
                                    ),
                                    onPressed: () => _toggleLike(postId, likes, context),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LikesScreen(postId: postId, ),
                                        ),
                                      );
                                    },
                                    child: Text('${likes.length}', style: const TextStyle(fontSize: 14)),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.comment_outlined, size: 18, color: Colors.grey.shade600),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CommentScreen(postId: postId, ),
                                        ),
                                      );
                                    },
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('reads')
                                        .doc(postId)
                                        .collection('comments')
                                        .snapshots(),
                                    builder: (context, commentSnapshot) {
                                      if (!commentSnapshot.hasData) return const Text('0');
                                      return Text(
                                        '${commentSnapshot.data!.docs.length}',
                                        style: const TextStyle(fontSize: 14),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ✅ LikeNotifier for Provider
class LikeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}