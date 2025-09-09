// lib/providers/post_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostProvider with ChangeNotifier {
  List<DocumentSnapshot> _myPosts = [];
  List<DocumentSnapshot> get myPosts => _myPosts;

  List<DocumentSnapshot> _userPosts = [];
  List<DocumentSnapshot> get userPosts => _userPosts;

  final _firestore = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> fetchMyPosts() async {
    final snapshot = await _firestore
        .collection('reads')
        .where('uid', isEqualTo: _uid)
        .orderBy('timestamp', descending: true)
        .get();
    _myPosts = snapshot.docs;
    notifyListeners();
  }

  Future<void> fetchUserPosts(String userId) async {
    final snapshot = await _firestore
        .collection('reads')
        .where('uid', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    _userPosts = snapshot.docs;
    notifyListeners();
  }

  Future<void> addPost(String text, String location, GeoPoint geo) async {
    await _firestore.collection('reads').add({
      'uid': _uid,
      'text': text,
      'location': location,
      'geo': geo,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });
    await fetchMyPosts(); // Refresh list
  }
}