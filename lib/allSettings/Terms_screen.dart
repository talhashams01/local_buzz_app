import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
        child: Scrollbar(
          radius: const Radius.circular(10),
          thickness: 4,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeading("Welcome to LocalBuzz"),
                _buildParagraph(
                    "By using our app, you agree to comply with the following terms and conditions. These terms apply to all users and govern your use of our platform."),

                const SizedBox(height: 20),
                _buildHeading("1. Eligibility"),
                _buildParagraph(
                    "You must be at least 13 years old to use this app. By creating an account, you confirm that you meet this age requirement."),

                const SizedBox(height: 20),
                _buildHeading("2. User Conduct"),
                _buildParagraph(
                    "You are responsible for all content you post. Do not share content that is harmful, abusive, illegal, or violates community guidelines."),

                const SizedBox(height: 20),
                _buildHeading("3. Content Ownership"),
                _buildParagraph(
                    "You retain ownership of the content you create, but by posting on LocalBuzz, you grant us a non-exclusive license to display and distribute it."),

                const SizedBox(height: 20),
                _buildHeading("4. Account Suspension"),
                _buildParagraph(
                    "We reserve the right to suspend or terminate your account if you violate any terms, engage in harmful behavior, or misuse the platform."),

                const SizedBox(height: 20),
                _buildHeading("5. Changes to Terms"),
                _buildParagraph(
                    "We may update these terms at any time. Continued use of the app after changes means you accept the new terms."),

                const SizedBox(height: 20),
                _buildHeading("6. Contact"),
                _buildParagraph(
                    "For questions or concerns, please contact us at: support@localbuzz.com"),

                const SizedBox(height: 40),
                const Text(
                  "Last updated: July 2025",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.6,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.6,
      ),
    );
  }
}