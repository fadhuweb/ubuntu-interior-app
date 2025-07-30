import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArtistOrderPage extends StatelessWidget {
  const ArtistOrderPage({super.key});

  Stream<List<Map<String, dynamic>>> get artistOrdersStream {
    final artistUid = FirebaseAuth.instance.currentUser?.uid;
    if (artistUid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> artistOrders = [];

      for (final orderDoc in snapshot.docs) {
        final orderData = orderDoc.data();
        final itemStatusSnap = await orderDoc.reference
            .collection('itemStatus')
            .where('artistId', isEqualTo: artistUid)
            .get();

        final artistItems = itemStatusSnap.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'],
            'quantity': data['quantity'],
            'status': data['status'],
            'ref': doc.reference,
          };
        }).toList();

        if (artistItems.isNotEmpty) {
          artistOrders.add({
            'orderId': orderDoc.id,
            'customerId': orderData['userId'],
            'date': orderData['date'],
            'items': artistItems,
          });
        }
      }

      return artistOrders;
    });
  }

  Future<void> _updateStatus(
      DocumentReference docRef, String newStatus, BuildContext context) async {
    try {
      await docRef.update({'status': newStatus});

      final orderId = docRef.parent.parent?.id;
      if (orderId != null && newStatus == 'Delivered') {
        await _checkAndMarkOrderDelivered(orderId);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to "$newStatus"')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _checkAndMarkOrderDelivered(String orderId) async {
    final itemStatusSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .collection('itemStatus')
        .get();

    final allDelivered = itemStatusSnapshot.docs.every((doc) {
      final status = doc.data()['status'];
      return status == 'Delivered';
    });

    if (allDelivered) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Delivered'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Art Orders'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: artistOrdersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders for your artworks yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['orderId'];
              final customerId = order['customerId'];
              final date = (order['date'] as Timestamp?)?.toDate();
              final items = List<Map<String, dynamic>>.from(order['items']);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: $orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (date != null)
                        Text('Date: ${date.toLocal().toString().split(" ")[0]}'),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(customerId)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return const SizedBox();
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                          final customerName = userData?['name'] ?? 'Unknown Customer';
                          return Text('Ordered by: $customerName');
                        },
                      ),
                      const Divider(height: 24),
                      ...items.map((item) {
                        final title = item['title'] ?? 'Untitled';
                        final quantity = item['quantity'] ?? 1;
                        final docRef = item['ref'] as DocumentReference;

                        return StreamBuilder<DocumentSnapshot>(
                          stream: docRef.snapshots(),
                          builder: (context, itemSnapshot) {
                            if (!itemSnapshot.hasData) return const SizedBox();
                            final status = itemSnapshot.data?.get('status') ?? 'Pending';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Artwork: $title', style: const TextStyle(fontSize: 16)),
                                Text('Quantity: $quantity'),
                                Row(
                                  children: [
                                    const Text('Status:'),
                                    const SizedBox(width: 12),
                                    DropdownButton<String>(
                                      value: status,
                                      items: const [
                                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                        DropdownMenuItem(value: 'Processing', child: Text('Processing')),
                                        DropdownMenuItem(value: 'Shipped', child: Text('Shipped')),
                                        DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                                      ],
                                      onChanged: (newValue) {
                                        if (newValue != null && newValue != status) {
                                          _updateStatus(docRef, newValue, context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        );
                      }),
                    ],
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
