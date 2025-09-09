import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsProvider extends ChangeNotifier {
  final String postId;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController commentController = TextEditingController();

  CommentsProvider(this.postId);

  Stream<QuerySnapshot> get commentStream => FirebaseFirestore.instance
      .collection('reads')
      .doc(postId)
      .collection('comments')
      .orderBy('timestamp', descending: true)
      .snapshots();

  Future<void> addComment(BuildContext context) async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('reads')
          .doc(postId)
          .collection('comments')
          .add({
        'uid': currentUserId,
        'text': text,
        'timestamp': Timestamp.now(),
      });

      final postDoc = await FirebaseFirestore.instance
          .collection('reads')
          .doc(postId)
          .get();

      final postData = postDoc.data() as Map<String, dynamic>;
      final postOwnerId = postData['uid'];
      final postText = postData['text'] ?? '';

      if (postOwnerId != currentUserId) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(postOwnerId)
            .collection('notifications')
            .add({
          'type': 'comment',
          'fromUserId': currentUserId,
          'readId': postId,
          'text': 'commented on your read',
          'postText': postText.length > 100
              ? postText.substring(0, 100)
              : postText,
          'commentText': text.length > 100
              ? text.substring(0, 100)
              : text,
          'timestamp': Timestamp.now(),
          'seen': false,
        });
      }

      commentController.clear();
      notifyListeners();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
    }
  }

  Future<void> deleteComment(BuildContext context, String commentId) async {
    final postRef = FirebaseFirestore.instance.collection('reads').doc(postId);

    try {
      await postRef.collection('comments').doc(commentId).delete();
      await postRef.update({'commentCount': FieldValue.increment(-1)});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete comment: $e")),
      );
    }
  }

  Future<void> editComment(
      BuildContext context, String commentId, String oldText) async {
    final controller = TextEditingController(text: oldText);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Comment"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Enter new comment"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Update"),
            onPressed: () async {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('reads')
                      .doc(postId)
                      .collection('comments')
                      .doc(commentId)
                      .update({
                    'text': newText,
                    'timestamp': Timestamp.now(),
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update: $e")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Comment cannot be empty")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}