import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookmarksProvider extends ChangeNotifier {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  List<DocumentSnapshot> bookmarks = [];
  bool isLoading = true;

  BookmarksProvider() {
    fetchBookmarks();
  }

  void fetchBookmarks() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      bookmarks = snapshot.docs;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> removeBookmark(String postId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(postId)
        .delete();

    // Removal will auto-refresh due to stream listener
    notifyListeners();
  }
}