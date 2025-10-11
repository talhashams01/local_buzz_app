

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