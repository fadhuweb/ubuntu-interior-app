import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'receipt_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.brown.shade700,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data() as Map<String, dynamic>;

              // ✅ Add Firestore doc ID as orderId
              final fullOrderData = {
                ...order,
                'orderId': orderDoc.id,
              };

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderDoc.id)
                    .collection('itemStatus')
                    .get(),
                builder: (context, itemSnapshot) {
                  final itemStatus = itemSnapshot.data?.docs ?? [];
                  return _buildOrderCard(context, fullOrderData, itemStatus);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
    List<QueryDocumentSnapshot> itemStatusDocs,
  ) {
    final String itemSummary = itemStatusDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title'] ?? 'Untitled';
      final status = data['status'] ?? 'Pending';
      return "$title – $status";
    }).join('\n');

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
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
                      Text("Order: ${order['orderId']}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Placed on ${order['date'].toDate().toLocal().toString().split(" ")[0]}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items with status
            Text(itemSummary, style: const TextStyle(fontSize: 14, height: 1.4)),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPaymentRow(order['paymentMethod'] ?? 'Unknown'),
                Text(
                  '\$${(order['total'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptPage(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Receipt'),
                ),
              ],
            ),
          ],
        ),
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
}
