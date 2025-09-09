import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> likedUsers = [];
  bool isLoading = false;

  Future<void> fetchLikes(String postId) async {
    isLoading = true;
    likedUsers.clear();
    notifyListeners();

    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('reads')
          .doc(postId)
          .get();

      final List likes = postDoc.data()?['likes'] ?? [];

      for (final userId in likes) {
        if (userId == null || userId is! String) continue;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          likedUsers.add({
            'uid': userId,
            'name': userData['name'] ?? 'User',
          });
        }
      }
    } catch (e) {
      print("Error fetching likes: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}