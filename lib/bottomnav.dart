
import 'package:flutter/material.dart';
import 'package:local_buzz_app/screens/Notification_screen.dart';
import 'package:local_buzz_app/screens/home_feed_screen.dart';
import 'package:local_buzz_app/screens/my_profile_screen.dart';
//import 'package:local_buzz_app/screens/otherscreens/poll_creation_screen.dart';
//import 'package:local_buzz_app/screens/post_read_screen.dart';
import 'package:local_buzz_app/screens/search_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/notification_seen_provider.dart';
import 'package:local_buzz_app/screens/trending_posts_screen.dart';
import 'package:provider/provider.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeFeedScreen(key: PageStorageKey('HomeFeed')),
    const TrendingScreen(key: PageStorageKey('Trending')),
    const SearchScreen(key: PageStorageKey('Search')),
    const NotificationsTab(key: PageStorageKey('Notifications')),
    MyProfileScreen(key: PageStorageKey('Profile')),
  ];

  void _onItemTapped(int index) async{
    setState(() => _selectedIndex = index);
    if(index == 3){
      await Future.delayed(const Duration(milliseconds: 300));

      Provider.of<NotificationSeenProvider>(context, listen: false).markAllAsSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home Feed",
            tooltip: 'Home Feed'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            label: "Trending",
            tooltip: 'Trending'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
            tooltip: 'Search'
          ),
          BottomNavigationBarItem(
            icon: Consumer<NotificationSeenProvider>(
              builder: (context, provider, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    if (provider.hasUnread)
                      const Positioned(
                        right: -2,
                        top: -2,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.red,
                        ),
                      ),
                  ],
                );
              },
            ),
            label: "Notifications",
            tooltip: 'Notifications'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: "Profile",
            tooltip: 'Profile'
          ),
        ],
      ),
    );
  }
}