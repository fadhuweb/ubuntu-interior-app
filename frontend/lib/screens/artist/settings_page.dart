import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'package:ubuntu_app/screens//help_page.dart';
import 'package:ubuntu_app/screens/privacy_page.dart';
import 'package:ubuntu_app/screens/login_page.dart'; // Make sure this exists

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color startColor = const Color(0xFFE95420);
    final Color endColor = const Color(0xFFFF6B35);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person, color: startColor),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.help_outline, color: startColor),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.lock, color: startColor),
            title: const Text('Privacy & Data'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
