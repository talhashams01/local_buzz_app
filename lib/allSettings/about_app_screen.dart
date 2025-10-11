


import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
  }

  Future<void> _fetchAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About App")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "📱 About the App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              "Local Buzz is a community-driven social platform designed to keep you connected with the latest happenings around your location. Discover trending posts, interact with people nearby, and stay engaged — all within a 100 km radius. Whether it’s thoughts, opinions, or local updates, this app brings real-time buzz from your surroundings.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Features
            const Text(
              "Core Features",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const FeatureBullet("📰 Unified Feed: Seamlessly view and interact with both Reads and Polls in one scrollable feed and also separately in both reads and polls tab."),
            const FeatureBullet("🔥 Trending Content: See what’s popular based on real engagement"),
            const FeatureBullet("📍 Location-Based Relevance: Discover posts within 100 km of your current location"),
            const FeatureBullet("🔔 Real-Time Notifications: Get instantly notified for likes and comments."),
            const FeatureBullet("❤ Engagement Tools: Like, comment, bookmark, share, and copy with ease"),
            const FeatureBullet("📤 Post Management: Create and delete your own reads and polls freely"),
            const SizedBox(height: 24),

            // App Info
            const Text(
              "App Info",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InfoRow(label: "Version", value: appVersion.isNotEmpty ? appVersion : "Loading..."),
            const InfoRow(label: "Developed By", value: "Talha Shams"),
           SizedBox(height: 30,) 
            //const InfoRow(label: "Built With", value: "Flutter & Firebase"),
            //const InfoRow(label: "Release Date", value: "July 2025"),
          ],
        ),
      ),
    );
  }
}

class FeatureBullet extends StatelessWidget {
  final String text;
  const FeatureBullet(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
