

import 'package:flutter/material.dart';
import 'package:local_buzz_app/screens/otherscreens/likes_provider.dart';
import 'package:provider/provider.dart';
//import 'package:local_buzz_app/screens/otherscreens/providers/likes_provider.dart';

class LikesScreen extends StatefulWidget {
  final String postId;

  const LikesScreen({Key? key, required this.postId, }) : super(key: key);

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<LikesProvider>(context, listen: false);
    provider.fetchLikes(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liked by")),
      body: Consumer<LikesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.likedUsers.isEmpty) {
            return const Center(child: Text("No likes yet."));
          }

          return ListView.builder(
            itemCount: provider.likedUsers.length,
            itemBuilder: (context, index) {
              final user = provider.likedUsers[index];

              return ListTile(
                title: Text(user['name']),
                subtitle: const Text("liked this post"),
                // Optionally add onTap for profile
              );
            },
          );
        },
      ),
    );
  }
}