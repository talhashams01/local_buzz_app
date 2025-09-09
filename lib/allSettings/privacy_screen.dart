import 'package:flutter/material.dart';

class PolicyScreen extends StatelessWidget {
  final String title;
  const PolicyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final String content = title == "Privacy Policy"
        ? _privacyPolicyContent
        : _termsAndConditionsContent;
        

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Scrollbar(
          thickness: 4,
          radius: const Radius.circular(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sample Privacy Policy
const String _privacyPolicyContent = '''
We value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and protect your data while you use our social sharing app.

1. Information We Collect

Personal Data: Name, email, phone number etc (from signup/login methods).

User-Generated Content: Posts (“reads”), Polls, likes, comments, and bookmarks.

Usage Data: App activity, timestamps, and interaction patterns.

Location Data (Essential for Functionality):

Our app relies on your device's location to deliver personalized, nearby content. We collect and use real-time location data to:

Display posts(Reads) and updates within a 100 km radius of your current location.

Ensure relevance of the content shown in your feed.

Enable core features like trending reads based on Reads engagement.

> 🚨 Important: If location access is denied or disabled:

The app will not display content in your feed(Enable your location before opening the apps)).

Most features dependent on proximity will not function correctly.

You may experience limited or broken functionality.

We do not track or store your location history. Location data is used solely for in-app relevance and is never shared with third parties.

2. How We Use Your Information

To display and share user-generated content with other users.

To personalize your experience (e.g., showing trending content).

To improve app functionality and fix issues based on usage analytics.

3. Data Sharing and Disclosure

We do not sell your personal data.

Public content (like posts(Reads), Polls, likes, and comments) is visible to other users.

We may share data with law enforcement if legally required.

4. Data Storage and Security

All data is stored securely using Firebase services.

We implement modern security practices to safeguard your information.

5. Your Rights

You can request to delete your account or data anytime.

6. Third-Party Services

This app may integrate services like Firebase, Google Login, and Share+.

These services may collect data as per their own privacy policies.

7. Children’s Privacy

Our app is not intended for children under the age of 12.

8. Changes to Policy

We may update this policy from time to time. Significant changes will be notified in the app.

If you have questions, contact us at: [shamscode101@gmail.come]
''';

// Sample Terms & Conditions
const String _termsAndConditionsContent = '''
Please read these Terms & Conditions carefully before using our app. By accessing or using the app, you agree to be bound by these Terms.

1. User Responsibilities

You agree to post respectful, original, and non-harmful content.

You must not post anything illegal, fake, hateful, threatening, or abusive.

You are responsible for your own posts and interactions.

2. Content Ownership

You retain ownership of your content but grant us a license to display it within the app.

We may remove or moderate any content that violates these Terms.

3. Account Security

Keep your login credentials confidential.

Notify us immediately of any unauthorized use of your account.

4. Prohibited Actions

Impersonating others or posting misleading/fake content.

Harassment, spamming, or exploiting the platform for commercial gain.

Attempting to hack, scrape, or disrupt our services.

5. Termination

We reserve the right to suspend or terminate your account if you violate these terms.

6. Limitation of Liability

We are not responsible for user-generated content or damages resulting from use of the app.

7. Changes to Terms

We may revise these Terms at any time. Continued use of the app means you accept the updates.

By using this app, you agree to comply with both these Terms & Conditions and our Privacy Policy.
''';
