import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const ReceiptPage({super.key, required this.order});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadItemStatus();
  }

  Future<void> _loadItemStatus() async {
    try {
      final orderId = widget.order['orderId'];
      final itemStatusSnap = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('itemStatus')
          .get();

      final fetchedItems = itemStatusSnap.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? 'Untitled',
          'quantity': data['quantity'] ?? 1,
          'price': (data['price'] ?? 0).toDouble(),
          'status': data['status'] ?? 'Pending',
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        items = fetchedItems;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final String orderId = order['orderId'] ?? 'N/A';
    final String paymentMethod = order['paymentMethod'] ?? 'N/A';

    final DateTime? dateTime = order['date']?.toDate();
    final String formattedDate = dateTime != null
        ? '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}'
        : 'N/A';

    final double totalAmount = (order['totalAmount'] ?? order['total'] ?? 0.0) is num
        ? (order['totalAmount'] ?? order['total'] ?? 0.0).toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Colors.brown.shade700,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Card(
                    color: Colors.brown.shade50,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Order ID:", orderId),
                          _infoRow("Date:", formattedDate),
                          _infoRow("Payment:", paymentMethod),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text("Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      )),
                  const SizedBox(height: 8),

                  ...items.map((item) {
                    final String title = item['title'];
                    final int quantity = item['quantity'];
                    final double price = item['price'];
                    final String status = item['status'];
                    final double itemTotal = price * quantity;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "$title x$quantity",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  "\$${itemTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text("Status: ",
                                    style: TextStyle(color: Colors.grey)),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(status),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  Divider(color: Colors.brown.shade300),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("\$${totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
