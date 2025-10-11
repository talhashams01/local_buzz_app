

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500));
    () {
      Provider.of<NotificationSeenProvider>(
        context,
        listen: false,
      ).markAllAsSeen();
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            );
          }

          final Map<String, List<QueryDocumentSnapshot>> grouped = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final label = _getLabel(timestamp);
            grouped.putIfAbsent(label, () => []).add(doc);
          }

          final labels = ['Today', 'Yesterday', 'This Week', 'Earlier'];

          return ListView(
            children: labels.where((l) => grouped[l] != null).expand((label) {
              return [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...grouped[label]!.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fromUserId = data['fromUserId'] ?? 'unknown';
                  final text = data['text'] ?? '';
                  final postText = data['postText'] ?? '';
                  final commentText = data['commentText'] ?? '';
                  final timestamp = (data['timestamp'] as Timestamp).toDate();
                  final type = data['type']?.toString() ?? 'unknown';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(fromUserId)
                        .get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData || !userSnap.data!.exists)
                        return const SizedBox();
                      final userData = userSnap.data!.data() as Map<String, dynamic>;
                      final username = userData['name'] ?? 'Someone';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.onPrimaryContainer,
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$username $text",
                                    style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (type == 'comment') ...[
                                    Text(
                                      "Read: $postText",
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Comment: $commentText",
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                  ] else if (type == 'like') ...[
                                    Text(
                                      "Read: $postText",
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      "(Unknown notification)",
                                      style: TextStyle(
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    timeago.format(timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ];
            }).toList(),
          );
        },
      ),
    );
  }

  String _getLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    if (date.isAfter(today)) return "Today";
    if (date.isAfter(yesterday)) return "Yesterday";
    if (date.isAfter(thisWeek)) return "This Week";
    return "Earlier";
  }
}


