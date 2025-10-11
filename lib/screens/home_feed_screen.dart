

//This code has 3 home tabs as all reads and polls, only reads, and only polls.


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:glassmorphism/glassmorphism.dart';
//import 'package:local_buzz_app/allSettings/block_users_screen.dart';
import 'package:local_buzz_app/screens/login_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/comment_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/fontsize_provider.dart';
import 'package:local_buzz_app/screens/otherscreens/likes_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/poll_creation_screen.dart';
//import 'package:local_buzz_app/screens/otherscreens/poll_creation_screen.dart';
//import 'package:local_buzz_app/screens/otherscreens/poll_creation_screen.dart';
import 'package:local_buzz_app/screens/post_read_screen.dart';
//import 'package:local_buzz_app/screens/otherscreens/poll_creation_screen.dart';
//import 'package:local_buzz_app/screens/post_read_screen.dart';
import 'package:local_buzz_app/screens/public_user_pofile.dart';
//import 'package:local_buzz_app/screens/otherscreens/bookmarks_screen.dart';
import 'package:local_buzz_app/widget/drawer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math';
import 'package:provider/provider.dart';


class LocationProvider with ChangeNotifier {
  Position? _position;
  bool _isLoading = true;

  Position? get position => _position;
  bool get isLoading => _isLoading;

  Future<void> fetchLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("❌ Error fetching location: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Added helper to force retry if location is still null later
  void retryIfNotFetched() {
    if (_position == null && !_isLoading) {
      fetchLocation();
    }
  }
}

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with SingleTickerProviderStateMixin {
  late String currentUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
     // setState(() {});
      // Needed to rebuild FAB on tab change
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Provider.of<LocationProvider>(context, listen: false).fetchLocation();
      // });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
  final locationProvider = Provider.of<LocationProvider>(context, listen: false);
  await locationProvider.fetchLocation();

  // 🔁 Retry after delay if location not fetched
  Future.delayed(const Duration(seconds: 2), () {
    locationProvider.retryIfNotFetched();
  });
});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> toggleLike(
    String postId,
    String ownerId,
    String postText,
  ) async {
    final postRef = FirebaseFirestore.instance.collection('reads').doc(postId);
    final snapshot = await postRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    final List currentLikes = data['likes'] ?? [];
    final isLiked = currentLikes.contains(currentUserId);

    await postRef.update({
      'likes': isLiked
          ? FieldValue.arrayRemove([currentUserId])
          : FieldValue.arrayUnion([currentUserId]),
    });
    print("🔄 Post liked status changed. isLiked before: $isLiked");

    if (!isLiked && currentUserId != ownerId) {
      print("🔔 Preparing to send LIKE notification to owner: $ownerId");

      final notificationRef = FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .collection('notifications')
          .doc();

      await notificationRef.set({
        'type': 'like',
        'fromUserId': currentUserId,
        'readId': postId,
        'text': 'liked your read',
        'timestamp': Timestamp.now(),
        'seen': false,
        'postText': postText.length > 50 ? postText.substring(0, 50) : postText,
      });
      print("✅ LIKE notification sent to $ownerId with seen: false");
    } else {
      print(
        "❌ Like notification not sent. Either it was already liked or user liked their own post.",
      );
    }
  }

  void showCreateOptionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text("New Read"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateReadScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.poll),
              title: const Text("New Poll"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PollCreationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget? buildFAB() {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          onPressed: showCreateOptionsSheet,
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateReadScreen()),
            );
          },
          child: const Icon(Icons.article),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PollCreationScreen()),
            );
          },
          child: const Icon(Icons.poll),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final position = locationProvider.position;


if (FirebaseAuth.instance.currentUser == null) {
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}

// 🟡 If location not fetched AND not currently loading, retry
if (position == null && !locationProvider.isLoading) {
  // Trigger location fetch again after user grants permission
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<LocationProvider>(context, listen: false).fetchLocation();
  });
}

// Show spinner until position is available
if (position == null) {
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}
 
       
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text("Buzz Feed"), centerTitle: true),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Reads'),
              Tab(text: 'Polls'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
      ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AllTabContent(
                  currentUserId: currentUserId,
                  position: position,
                  calculateDistance: calculateDistance,
                  toggleLike: toggleLike,
                ),
                ReadsTabContent(
                  currentUserId: currentUserId,
                  position: position,
                  calculateDistance: calculateDistance,
                  toggleLike: toggleLike,
                  isInAllTab: true,
                ),
                PollsTabContent(
                  position: position,
                  calculateDistance: calculateDistance,
              ),
              ],
          ),
      ),
          ],
    ),
      floatingActionButton: buildFAB(),
  );
  
  }
  
}





class AllTabContent extends StatelessWidget {
  final String currentUserId;
  final Position position;
  final double Function(dynamic lat1, dynamic lon1, dynamic lat2, dynamic lon2)
      calculateDistance;
  final Future<void> Function(String postId, String ownerId, String postText)
      toggleLike;

  const AllTabContent({
    Key? key,
    required this.currentUserId,
    required this.position,
    required this.calculateDistance,
    required this.toggleLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [Colors.grey.shade900, Colors.grey.shade800]
        : [Color(0xFFe0f7fa), Color(0xFFfce4ec)];
    final cardTextColor = isDark ? Colors.white : Colors.black87;

    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // POLLS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('polls')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, pollSnap) {
                if (!pollSnap.hasData) return const SizedBox();
                final polls = pollSnap.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final geo = data['geo'];
                  final timestamp = data['timestamp'] as Timestamp;
                  final pollAge = DateTime.now().difference(timestamp.toDate()).inHours;
                  final distance = calculateDistance(
                    position.latitude,
                    position.longitude,
                    geo.latitude,
                    geo.longitude,
                  );
                  return distance <= 100 && pollAge < 24;
                }).toList();

                return Column(
                  children: polls.map((pollDoc) {
                    final pollData = pollDoc.data() as Map<String, dynamic>;
                    return buildStyledCard(
                      context: context,
                      child: buildPollCard(pollData, pollDoc.id, ),
                      gradientColors: gradientColors,
                    );
                  }).toList(),
                );
              },
            ),

            // READS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reads')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final posts = snapshot.data!.docs.where((doc) {
                  try {
                    final geo = doc['geo'];
                    if (geo == null) return false;
                    final distance = calculateDistance(
                      position.latitude,
                      position.longitude,
                      geo.latitude,
                      geo.longitude,
                    );
                    return distance <= 100;
                  } catch (_) {
                    return false;
                  }
                }).toList();

                return Column(
                  children: posts.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final text = data['text'] ?? '';
                    final timestamp = data['timestamp']?.toDate();
                    final location = data['location'] ?? '';
                    final uid = data['uid'];
                    final List likes = data['likes'] ?? [];
                    final isLiked = likes.contains(currentUserId);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return const SizedBox();
                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        final name = userData['name'] ?? 'User';

                        return buildStyledCard(
                          context: context,
                          gradientColors: gradientColors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PublicProfileScreen(userId: uid),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.purple[100],
                                          child: Text(
                                            name[0].toUpperCase(),
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: cardTextColor,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (timestamp != null)
                                        Text(
                                          timeago.format(timestamp),
                                          style: TextStyle(fontSize: 12, color: cardTextColor),
                                        ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'delete') {
                                            await FirebaseFirestore.instance
                                                .collection('reads')
                                                .doc(doc.id)
                                                .delete();
                                          } else if (value == 'save') {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUserId)
                                                .collection('bookmarks')
                                                .doc(doc.id)
                                                .set({
                                                  'text': text,
                                                  'savedAt': Timestamp.now(),
                                                });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Post bookmarked")),
                                            );
                                          } else if (value == 'copy') {
                                            await Clipboard.setData(ClipboardData(text: text));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Text copied")),
                                            );
                                          } else if (value == 'share') {
                                            Share.share(text);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          if (uid == currentUserId)
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text("Delete"),
                                            ),
                                          const PopupMenuItem(
                                            value: 'save',
                                            child: Text("Bookmark"),
                                          ),
                                          const PopupMenuItem(
                                            value: 'copy',
                                            child: Text("Copy Text"),
                                          ),
                                          const PopupMenuItem(
                                            value: 'share',
                                            child: Text("Share"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Post Text
                              Consumer<FontSizeProvider>(
                                builder: (context, fontProvider, _) {
                                  return Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: fontProvider.fontSize,
                                      color: cardTextColor,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),

                              // Like, Comment, Location
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isLiked ? Icons.favorite : Icons.favorite_border,
                                          color: isLiked ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () => toggleLike(doc.id, uid, text),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LikesScreen(postId: doc.id),
                                          ),
                                        ),
                                        child: Text(
                                          "${likes.length}",
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.comment, color: Colors.grey),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => CommentScreen(postId: doc.id),
                                            ),
                                          );
                                        },
                                      ),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('reads')
                                            .doc(doc.id)
                                            .collection('comments')
                                            .snapshots(),
                                        builder: (context, commentSnap) {
                                          final count = commentSnap.data?.docs.length ?? 0;
                                          return Text("$count", style: const TextStyle(color: Colors.grey));
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        location,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ======= Fancy Gradient Card =======
  Widget buildStyledCard({
    required BuildContext context,
    required Widget child,
    required List<Color> gradientColors,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

}


// POLLS TAB
class PollsTabContent extends StatelessWidget {
  final Position position;
  final double Function(double, double, double, double) calculateDistance;

  const PollsTabContent({
    super.key,
    required this.position,
    required this.calculateDistance,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('polls')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, pollSnap) {
        if (!pollSnap.hasData) return const SizedBox();
        final polls = pollSnap.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final geo = data['geo'];
          final timestamp = data['timestamp'] as Timestamp;
          final pollAge = DateTime.now().difference(timestamp.toDate()).inHours;
          final distance = calculateDistance(
            position.latitude,
            position.longitude,
            geo.latitude,
            geo.longitude,
          );
          return distance <= 100 && pollAge < 24;
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 500));
          },
          child: Column(
            children: polls.map((pollDoc) {
              final pollData = pollDoc.data() as Map<String, dynamic>;
              return Column(
                children: [
                  buildPollCard(pollData, pollDoc.id),
                  const Divider(thickness: 1, color: Colors.grey),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// READS TAB
class ReadsTabContent extends StatelessWidget {
  final String currentUserId;
  final Position position;
  final double Function(double, double, double, double) calculateDistance;
  final Future<void> Function(String, String, String) toggleLike;

  const ReadsTabContent({
    super.key,
    required this.currentUserId,
    required this.position,
    required this.calculateDistance,
    required this.toggleLike,
    required bool isInAllTab,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reads')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final posts = snapshot.data!.docs.where((doc) {
          try {
            final geo = doc['geo'];
            if (geo == null) return false;
            final distance = calculateDistance(
              position.latitude,
              position.longitude,
              geo.latitude,
              geo.longitude,
            );
            return distance <= 100;
          } catch (_) {
            return false;
          }
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 500));
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final doc = posts[index];
              final data = doc.data() as Map<String, dynamic>;
              final text = data['text'] ?? '';
              final timestamp = data['timestamp']?.toDate();
              final location = data['location'] ?? '';
              final uid = data['uid'];
              final List likes = data['likes'] ?? [];
              final isLiked = likes.contains(currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final name = userData['name'] ?? 'User';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Info + Options Menu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PublicProfileScreen(userId: uid),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        child: Text(name[0].toUpperCase()),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (timestamp != null)
                                      Text(
                                        timeago.format(timestamp),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          await FirebaseFirestore.instance
                                              .collection('reads')
                                              .doc(doc.id)
                                              .delete();
                                        } else if (value == 'save') {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(currentUserId)
                                              .collection('bookmarks')
                                              .doc(doc.id)
                                              .set({
                                                'text': text,
                                                'savedAt': Timestamp.now(),
                                              });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Post bookmarked"),
                                            ),
                                          );
                                        } else if (value == 'copy') {
                                          await Clipboard.setData(
                                            ClipboardData(text: text),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Text copied"),
                                            ),
                                          );
                                        } else if (value == 'share') {
                                          Share.share(text);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        if (uid == currentUserId)
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text("Delete"),
                                          ),
                                        const PopupMenuItem(
                                          value: 'save',
                                          child: Text("Bookmark"),
                                        ),
                                        const PopupMenuItem(
                                          value: 'copy',
                                          child: Text("Copy Text"),
                                        ),
                                        const PopupMenuItem(
                                          value: 'share',
                                          child: Text("Share"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Post Text with Font Size Control
                            Consumer<FontSizeProvider>(
                              builder: (context, fontProvider, _) {
                                return Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: fontProvider.fontSize,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),

                            // Likes, Comments, Location
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isLiked
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          toggleLike(doc.id, uid, text),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              LikesScreen(postId: doc.id, ),
                                        ),
                                      ),
                                      child: Text(
                                        "${likes.length}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.comment,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CommentScreen(postId: doc.id, ),
                                        ),
                                      ),
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('reads')
                                          .doc(doc.id)
                                          .collection('comments')
                                          .snapshots(),
                                      builder: (context, commentSnap) {
                                        final count =
                                            commentSnap.data?.docs.length ?? 0;
                                        return Text(
                                          "$count",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                  ],
                              );
                },
          );
            },
                    ),
    );
            },
    );
  }
}

Widget buildPollCard(Map<String, dynamic> data, String pollId) {
  // same as your old buildPollCard – you can include it here as is.

  final question = data['question'] ?? '';
  final List options = data['options'] ?? [];
  final List votes = List<int>.from(data['votes'] ?? []);
  final totalVotes = votes.fold<int>(0, (sum, v) => sum + (v as int));
  final uid = data['uid'] ?? '';
  final votedMap = Map<String, dynamic>.from(data['voted'] ?? {});
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final hasVoted = votedMap.containsKey(currentUserId);
  final selectedOption = hasVoted ? votedMap[currentUserId] : -1;
  final timestamp = (data['timestamp'] as Timestamp).toDate();

  // ✅ Auto-delete if older than 24h
  if (DateTime.now().difference(timestamp).inHours >= 24) {
    FirebaseFirestore.instance.collection('polls').doc(pollId).delete();
    return const SizedBox.shrink();
  }

  // ✅ Expiry label logic
  final expiryDuration = Duration(hours: 24);
  final timeLeft = timestamp.add(expiryDuration).difference(DateTime.now());

  String expiryLabel;
  if (timeLeft.isNegative) {
    expiryLabel = "Expired";
  } else if (timeLeft.inHours > 0) {
    expiryLabel = "Expires in ${timeLeft.inHours}h";
  } else {
    expiryLabel = "Expires in ${timeLeft.inMinutes}m";
  }

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();
      final user = snapshot.data!.data() as Map<String, dynamic>;
      final name = user['name'] ?? 'User';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑 User Info + PopupMenu + Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicProfileScreen(userId: uid),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(child: Text(name[0].toUpperCase())),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          expiryLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: timeLeft.isNegative
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                        Text(
                          timeago.format(timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (uid == currentUserId)
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'delete') {
                            await FirebaseFirestore.instance
                                .collection('polls')
                                .doc(pollId)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Poll deleted")),
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'delete', child: Text("Delete")),
                        ],
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 📊 Poll Options
            ListView.builder(
              itemCount: options.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                final option = options[i];
                final percent = totalVotes == 0
                    ? 0
                    : (votes[i] / totalVotes) * 100;

                return GestureDetector(
                  onTap: () async {
                    if (hasVoted || currentUserId == null) return;

                    final updatedVotes = List<int>.from(votes);
                    updatedVotes[i] += 1;

                    await FirebaseFirestore.instance
                        .collection('polls')
                        .doc(pollId)
                        .update({
                          'votes': updatedVotes,
                          'voted.$currentUserId': i,
                        });

                    // Refresh UI
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedOption == i
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedOption == i
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 6),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final barMaxWidth = constraints.maxWidth;
                            final barWidth = barMaxWidth * (percent / 100);

                            return Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: barMaxWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // 📍 Total Votes & Location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total votes: $totalVotes",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      data['location'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
