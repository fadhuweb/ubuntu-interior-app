import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:ubuntu_app/utils/colors.dart';
// ignore: unused_import
import 'package:ubuntu_app/utils/text_styles.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Privacy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Privacy & Data Protection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔹 What We Collect:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('• Name, email, preferences, and app usage data.'),
                  Text('• Device info: IP address, OS, browser type.'),
                  Text('• In-app interactions and features used.'),

                  SizedBox(height: 12),
                  Text(
                    '🔹 Why We Collect It:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('• To improve service and personalize experience.'),
                  Text('• For customer support and app updates.'),
                  Text('• To enhance functionality and ensure security.'),

                  SizedBox(height: 12),
                  Text(
                    '🔹 How We Protect Your Data:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('• Secure servers and encryption techniques.'),
                  Text('• Limited access by authorized personnel.'),
                  Text('• Regular audits and privacy policy reviews.'),

                  SizedBox(height: 12),
                  Text(
                    '❌ What We Do NOT Do:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('• We never sell your personal data.'),
                  Text('• We never use your data without your consent.'),

                  SizedBox(height: 12),
                  Text(
                    '🛡️ Your Rights:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('• Access your personal data.'),
                  Text('• Request correction or deletion.'),
                  Text('• Withdraw consent at any time.'),
                  Text('• Object to how we use your data.'),
                  Text('• Lodge a complaint with a data protection authority.'),

                  SizedBox(height: 12),
                  Text(
                    '📬 Contact Information:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('For privacy inquiries or questions:'),
                  Text('Email: privacy@yourapp.com'),
                  Text('Phone: +1 234 567 8901'),
                  Text('Address: 123 Privacy Lane, Tech City, USA'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
