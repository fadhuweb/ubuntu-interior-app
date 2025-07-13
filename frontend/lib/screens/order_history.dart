import 'package:flutter/material.dart';
import 'tracking_page.dart'; // Make sure this path is correct

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          OrderTile(
            orderNumber: '#12345',
            date: 'March 15, 2024',
            status: 'Delivered',
            total: '\$45.99',
            items: 'Coffee Beans, Pastries',
          ),
          OrderTile(
            orderNumber: '#12344',
            date: 'March 10, 2024',
            status: 'Shipped',
            total: '\$23.50',
            items: 'Cappuccino, Sandwich',
          ),
          OrderTile(
            orderNumber: '#12343',
            date: 'March 5, 2024',
            status: 'Pending',
            total: '\$15.75',
            items: 'Latte, Croissant',
          ),
        ],
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final String orderNumber;
  final String date;
  final String status;
  final String total;
  final String items;

  const OrderTile({
    super.key,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.green;
    if (status == 'Pending') {
      statusColor = Colors.orange;
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Order details
            Text(
              'Date: $date',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text('Items: $items', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),

            // Total + Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: $total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reorder functionality coming soon!'),
                          ),
                        );
                      },
                      child: const Text('Reorder'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TrackingPage()),
                        );
                      },
                      child: const Text('Track Order'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
