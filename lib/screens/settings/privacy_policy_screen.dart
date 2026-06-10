// lib/screens/settings/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('PoultryBooks Privacy Policy',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
          const SizedBox(height: 4),
          Text('Last updated: January 2026',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          _section(
              '1. Information We Collect',
              'PoultryBooks collects the following information to provide its services:\n\n'
                  '• Email address (for account creation and login)\n'
                  '• Farm name and settings you enter\n'
                  '• Farm records you create: egg logs, sales, expenses, customer details, and flock information\n\n'
                  'We do not collect any information automatically beyond what you voluntarily enter into the app.'),
          _section(
              '2. How We Use Your Information',
              'Your information is used solely to:\n\n'
                  '• Provide and maintain your PoultryBooks account\n'
                  '• Sync your farm records across devices via Firebase\n'
                  '• Allow you to retrieve your data when you sign in\n\n'
                  'We do not use your data for advertising, analytics, or any purpose beyond operating the app.'),
          _section(
              '3. Data Storage',
              'Your data is stored in two places:\n\n'
                  '• On your device (offline-first storage using Hive)\n'
                  '• In Google Firebase (cloud backup and sync)\n\n'
                  'Firebase is operated by Google LLC and is subject to Google\'s privacy policies. '
                  'Your data is stored securely and is only accessible to your account.'),
          _section(
              '4. Data Sharing',
              'We do not sell, trade, or share your personal information with any third parties. '
                  'Your farm records are private and visible only to you when logged into your account.'),
          _section(
              '5. Data Security',
              'We implement appropriate security measures to protect your information:\n\n'
                  '• All data transmission is encrypted using HTTPS\n'
                  '• Firebase security rules ensure only you can access your data\n'
                  '• Passwords are managed by Firebase Authentication and are never stored in plain text'),
          _section(
              '6. Your Rights',
              'You have the right to:\n\n'
                  '• Access all data stored in your account\n'
                  '• Delete your account and all associated data at any time\n'
                  '• Export your records at any time\n\n'
                  'To delete your account and all data, please contact us at the email below.'),
          _section(
              '7. Children\'s Privacy',
              'PoultryBooks is not directed at children under the age of 13. '
                  'We do not knowingly collect personal information from children.'),
          _section(
              '8. Changes to This Policy',
              'We may update this privacy policy from time to time. '
                  'We will notify you of any significant changes by updating the date at the top of this page. '
                  'Continued use of the app after changes constitutes acceptance of the updated policy.'),
          _section(
              '9. Contact Us',
              'If you have any questions about this privacy policy or your data, please contact us at:\n\n'
                  'poultrybooks.app@gmail.com'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.6)),
        ]),
      );
}
