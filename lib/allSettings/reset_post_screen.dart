import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPostsScreen extends StatefulWidget {
  const ResetPostsScreen({super.key});

  @override
  State<ResetPostsScreen> createState() => _ResetPostsScreenState();
}

class _ResetPostsScreenState extends State<ResetPostsScreen> {
  bool isDeleting = false;

  Future<void> deleteAllUserPosts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => isDeleting = true);

    try {
      final reads = await FirebaseFirestore.instance
          .collection('reads')
          .where('uid', isEqualTo: uid)
          .get();

      final polls = await FirebaseFirestore.instance
          .collection('polls')
          .where('uid', isEqualTo: uid)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in reads.docs) {
        batch.delete(doc.reference);
      }

      for (var doc in polls.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ All Reads & Polls have been deleted.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error deleting posts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset My Posts")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This will permanently delete all your reads and polls. "
              "This action cannot be undone.",
              style: TextStyle(fontSize: 16, color: Color.fromARGB(221, 214, 19, 19)),
              
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: isDeleting
                    ? const Text("Deleting...")
                    : const Text("Reset Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 224, 100, 91),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: isDeleting ? null : deleteAllUserPosts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}