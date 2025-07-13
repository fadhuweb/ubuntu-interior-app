import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          NotificationTile(
            title: 'Order Shipped',
            message: 'Your order #12345 has been shipped.',
            timestamp: '2 hours ago',
          ),
          NotificationTile(
            title: 'New Promotion!',
            message: 'Get 20% off your next order. Use code SAVE20.',
            timestamp: 'Yesterday',
          ),
          NotificationTile(
            title: 'Welcome to the App',
            message: 'Thank you for signing up!',
            timestamp: '2 days ago',
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String timestamp;

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Colors.brown),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
