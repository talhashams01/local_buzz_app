// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class NotificationSeenProvider extends ChangeNotifier {
//   bool _hasUnread = false;
//   bool get hasUnread => _hasUnread;

//   void listenToNotifications() {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       final newValue = snapshot.docs.isNotEmpty;
//       if (_hasUnread != newValue) {
//         _hasUnread = newValue;
//         notifyListeners(); // Notify UI
//       }
//     });
//   }

//   void markAllAsSeen() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (var doc in query.docs) {
//       batch.update(doc.reference, {'seen': true});
//     }

//     await batch.commit();
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

// class NotificationSeenProvider with ChangeNotifier {
//   bool hasUnread = false;

//   NotificationSeenProvider() {
//     _listenToUnseenNotifications();
//   }

//   void _listenToUnseenNotifications() {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;

//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       hasUnread = snapshot.docs.isNotEmpty;
//       notifyListeners();
//     });
//   }

//   Future<void> markAllAsSeen(String currentUserId) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;

//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (var doc in query.docs) {
//       batch.update(doc.reference, {'seen': true});
//     }
//     await batch.commit();

//     hasUnread = false;
//     notifyListeners();
//   }
// }


// lib/screens/otherscreens/notification_seen_provider.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

// class NotificationSeenProvider with ChangeNotifier {
//   bool hasUnread = false;

//   // NotificationSeenProvider() {
//   //   _listenToUnseenNotifications();
//   // }

//   // void _listenToUnseenNotifications() {
//   //   final userId = FirebaseAuth.instance.currentUser?.uid;
//   //   if (userId == null) return;

//   //   FirebaseFirestore.instance
//   //       .collection('users')
//   //       .doc(userId)
//   //       .collection('notifications')
//   //       .where('seen', isEqualTo: false)
//   //       .snapshots()
//   //       .listen((snapshot) {
//   //     hasUnread = snapshot.docs.isNotEmpty;
//   //     print('NotificationSeenProvider: ${snapshot.docs.length}');
//   //     notifyListeners();
//   //   });
//   // }
// NotificationSeenProvider() {
// //  _listenToUnseenNotifications();

//   // Force check once on init as backup
//   checkUnreadStatusOnce();
// }

// Future<void> checkUnreadStatusOnce() async {
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null) return;

//   final snapshot = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('notifications')
//       .where('seen', isEqualTo: false)
//       .get();

//   hasUnread = snapshot.docs.isNotEmpty;
//   notifyListeners();
// }
//   Future<void> markAllAsSeen() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;

//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (var doc in query.docs) {
//       batch.update(doc.reference, {'seen': true});
//     }
//     await batch.commit();

//     hasUnread = false;
//     notifyListeners();
//   }
// }



// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

// class NotificationSeenProvider with ChangeNotifier {
//   bool hasUnread = false;
//   StreamSubscription? _subscription;
//   String? _lastUserId;

//   NotificationSeenProvider() {
//     _initListener();
//   }

//   void _initListener() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null || user.uid == _lastUserId) return;

//     _lastUserId = user.uid;

//     _subscription?.cancel();

//     _subscription = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       final previous = hasUnread;
//       hasUnread = snapshot.docs.isNotEmpty;

//       print('🔴 Unread status changed: $previous → $hasUnread');

//       if (hasUnread != previous) notifyListeners();
//     });
//   }

//   Future<void> markAllAsSeen() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     print('✅ Marking all notifications as seen for user: ${user.uid}');

//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('notifications')
//         .where('seen', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (var doc in query.docs) {
//       batch.update(doc.reference, {'seen': true});
//     }
//     await batch.commit();

//     hasUnread = false;
//     notifyListeners();
//   }

//   void refresh({required bool refresh}) {
//     _initListener();
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }



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