import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = [
      {
        'title': 'Kente Cushion',
        'date': 'July 28, 2025',
        'status': 'Delivered',
        'payment': 'Mobile Money',
        'total': 45.99
      },
      {
        'title': 'Ceramic Vase',
        'date': 'July 25, 2025',
        'status': 'In Transit',
        'payment': 'Visa',
        'total': 34.50
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.brown.shade700,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.brown.shade100,
                        child: Icon(Icons.shopping_bag, color: Colors.brown.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order['title'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Ordered on ${order['date']}'),
                          ],
                        ),
                      ),
                      _buildStatusChip(order['status']),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPaymentRow(order['payment']),
                      Text('\$${order['total'].toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (order['status'] != 'Delivered')
                        TextButton.icon(
                          onPressed: () => _showMessage(context, 'Tracking order...'),
                          icon: const Icon(Icons.local_shipping),
                          label: const Text('Track'),
                        ),
                      TextButton.icon(
                        onPressed: () => _showMessage(context, 'Showing receipt for ${order['title']}'),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Receipt'),
                      ),
                      if (order['status'] == 'Delivered')
                        ElevatedButton(
                          onPressed: () => _showMessage(context, 'Thanks for rating!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Rate'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor = status == 'Delivered' ? Colors.green.shade100 : Colors.orange.shade100;
    Color textColor = status == 'Delivered' ? Colors.green.shade800 : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPaymentRow(String method) {
    IconData icon;
    switch (method) {
      case 'Mobile Money':
        icon = Icons.phone_android;
        break;
      case 'Visa':
        icon = Icons.credit_card;
        break;
      case 'PayPal':
        icon = Icons.account_balance_wallet;
        break;
      default:
        icon = Icons.payment;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.brown),
        const SizedBox(width: 4),
        Text(method, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
