



import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationSeenProvider with ChangeNotifier {
  bool hasUnread = false;
  StreamSubscription? _subscription;
  String? _lastUserId;

  NotificationSeenProvider() {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.uid != _lastUserId) {
        _lastUserId = user.uid;
        _listenToUnseenNotifications(user.uid);
      }
    });
  }

  void _listenToUnseenNotifications(String userId) {
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('seen', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      final previous = hasUnread;
      hasUnread = snapshot.docs.isNotEmpty;

      if (previous != hasUnread) {
        notifyListeners();
      }
    });
  }

   Future<void> markAllAsSeen() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ No user signed in. Cannot mark notifications as seen.');
    return;
  }

  print('📍 Attempting to mark notifications as seen for ${user.uid}');

  try {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('seen', isEqualTo: false)
        .get();

    print('📥 Found ${query.docs.length} unseen notifications');

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in query.docs) {
      print('✅ Marking ${doc.id} as seen');
      batch.update(doc.reference, {'seen': true});
    }

    await batch.commit();
    print('🎉 All notifications marked as seen');

    hasUnread = false;
    notifyListeners();
  } catch (e) {
    print('🔥 Failed to mark notifications as seen: $e');
  }
}

    

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}