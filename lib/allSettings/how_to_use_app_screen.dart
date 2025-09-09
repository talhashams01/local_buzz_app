import 'package:flutter/material.dart';

class HowToUseAppScreen extends StatelessWidget {
  const HowToUseAppScreen({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📖 How to Use App")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          UsageCard(
            icon: Icons.feed,
            title: "1. Explore Local Feed",
            description:
                "The Home screen shows all Reads and Polls posted by people around you (within 100 km). Stay connected with what’s happening nearby.",
          ),
          UsageCard(
            icon: Icons.add_circle_outline,
            title: "2. Post a Read or Poll",
            description:
                "Tap the '+' button to write your thoughts as a Read or ask a question as a Poll. Add your message, and let the local community engage.",
          ),
          UsageCard(
            icon: Icons.favorite_border,
            title: "3. Like & View Likes",
            description:
                "Tap the ❤ icon to like a post. Tap the like count number to view everyone who liked it.",
          ),
          UsageCard(
            icon: Icons.comment,
            title: "4. Comment & Engage",
            description:
                "Tap the 💬 icon to read or write comments. Your discussions help keep the community alive.",
          ),
          UsageCard(
            icon: Icons.trending_up,
            title: "5. Trending Tab",
            description:
                "See what’s buzzing! Posts with more engagement appear in the Trending Section.",
          ),
          UsageCard(
            icon: Icons.notifications_active,
            title: "6. Real-time Notifications",
            description:
                "Stay updated instantly when someone likes or comments on your posts(Reads).",
          ),
          UsageCard(
            icon: Icons.location_on,
            title: "7. Location Access Required",
            description:
                "Ensure location is enabled before opening the app. It filters and shows posts only within your 100 km area for relevance.",
            highlight: true,
          ),
          UsageCard(
            icon: Icons.bookmark_border,
            title: "8. Bookmark Posts",
            description:
                "Save posts you find helpful or want to revisit later. Access them anytime in the Bookmarks section.",
          ),
          UsageCard(
            icon: Icons.manage_accounts,
            title: "9. Edit or Delete Your Posts",
            description:
                "Posted something by mistake? No worries. Tap the three dots on your post to delete it.",
          ),
          UsageCard(
            icon: Icons.share,
            title: "10. Share with Others",
            description:
                "Use the share or copy options to spread great content via other apps or with friends.",
          ),
          UsageCard(
            icon: Icons.menu,
            title: "11. App Drawer Navigation",
            description:
                "Tap the menu icon (☰) to open the Drawer where you can visit your profile, access bookmarks, and view your saved locations.",
          ),
          UsageCard(
            icon: Icons.place,
            title: "12. Saved Locations",
            description:
                "Easily access your own reads posted from a specific place! When you open any location from saved locations, you can view only your reads shared from that spot.",
          ),
          UsageCard(
            icon: Icons.person,
            title: "13. View and Manage Profiles",
            description:
                "Visit your own profile via the Drawer or last tab andtap on any name in the feed to view the users profile and reads.",
          ),
          UsageCard(
            icon: Icons.search,
            title: "14. Use the Search Feature",
            description:
                "Tap the search icon to search users. It helps you quickly find people within your local area(100 km radius).",
          ),
          UsageCard(
            icon: Icons.settings,
            title: "15. Access App Settings",
            description:
                "In your profile, tap the ⚙ settings icon in the AppBar to customize your experience — change theme, font size, manage security, and view app info.",
          ),
        ],
      ),
    );
  }
}

class UsageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool highlight;

  const UsageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight
          ? const Color.fromARGB(255, 143, 139, 139)
          : const Color.fromARGB(255, 143, 139, 139),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: highlight ? Colors.red : Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
