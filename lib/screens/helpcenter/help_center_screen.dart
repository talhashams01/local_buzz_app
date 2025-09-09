import 'package:flutter/material.dart';
//import 'package:local_buzz_app/screens/help_detail_screen.dart';
import 'package:local_buzz_app/screens/helpcenter/help_detail_screen.dart';
//import 'help_detail_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  final List<Map<String, String>> helpItems = [
    {
      'question': 'What is LocalBuzz and how does it work?',
      'answer':
          'LocalBuzz is a location-based social platform where you can share reads, polls, and connect with users near you. It uses your device location to show relevant content within a 100 km radius.'
    },
    {
      'question': 'Why does the app need my location?',
      'answer':
          'Your location ensures you get content from nearby users. It’s essential for showing local posts, trending reads, and nearby polls.'
    },
    {
      'question': 'How to create or edit my profile?',
      'answer':
          'Go to the drawer menu, tap on your account to view or edit your profile. You can change your personal details.'
    },
    
    {
      'question': 'What is the purpose of saved locations?',
      'answer':
          'Your all posted locations are saved through which you can see those reads which are associated with the specific location.  These are accessible from the drawer for quick navigation.'
    },
    {
      'question': 'How to reset password or secure my account?',
      'answer':
          'Go to the Account > Change Password. There you can reset your password or update your account credentials.'
    },
    {
      'question': 'What to do if content is not loading?',
      'answer':
          'Ensure your location is turned ON before opening the app(Not during the app) and internet is stable. Restart the app and try again. Contact support if issue continues.'
    },
  {
    'question': 'How do I post a read?',
    'answer': 'Tap the + button, type your content, wait for the location to appear below the text field, then tap Post.'
  },
  {
    'question': 'Why should I wait for location while posting?',
    'answer': 'Location ensures your read is visible to users near you (within 100km). Without location, your post may not reach others in your area.'
  },
  {
    'question': 'How do reads appear in Trending?',
    'answer': 'A read appears in Trending when it gets more user engagement within 48 hours(Aftet 2 days it will remove from trending).'
  },
  
  {
    'question': 'How can I bookmark a post?',
    'answer': 'Tap the 3 dots menu on any read and click bookmark. It will be saved in your Bookmarks section from the drawer.'
  },
  
  {
    'question': 'How do I visit other users’ profiles?',
    'answer': 'Tap any username on a read to open that user’s public profile and see their reads.'
  },
  
  {
    'question': 'How do I change the app theme?',
    'answer': 'Go to Settings (via profile screen) → Theme → Choose Light, Dark, or system default mode.'
  },
  {
    'question': 'How can I increase or decrease font size?',
    'answer': 'Go to Settings → Font Size -> to select your preferred text size for easier reading.'
  },
  {
    'question': 'How do I set a password or PIN?',
    'answer': 'Go to Settings → App Lock -> to enable and set a PIN for app access.'
  },
  {
    'question': 'How do I reset my app settings?',
    'answer': 'Go to Settings → Reset My Posts -> to clear all your reads.'
  },
  {
    'question': 'What is the use of the search feature?',
    'answer': 'You can search users by their username. This helps quickly discover profiles.'
  },

    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help Center")),
      body: ListView.separated(
        itemCount: helpItems.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final item = helpItems[index];
          return ListTile(
            title: Text(item['question']!),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HelpDetailScreen(
                    question: item['question']!,
                    answer: item['answer']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}