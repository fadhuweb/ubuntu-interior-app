import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'payment_screen.dart'; // ✅ Import your payment screen

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> get cartStream =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('cart').snapshots();

  void _updateQuantity(DocumentSnapshot cartDoc, int delta) async {
    final currentQty = cartDoc['quantity'] ?? 1;
    final newQty = currentQty + delta;

    if (newQty <= 0) {
      await cartDoc.reference.delete();
      _showSnackBar('Item removed from cart', Colors.red);
    } else {
      await cartDoc.reference.update({'quantity': newQty});
    }
  }

  void _removeItem(DocumentSnapshot cartDoc) async {
    await cartDoc.reference.delete();
    _showSnackBar('Item removed from cart', Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _continueShopping() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Shopping Cart', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _continueShopping,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading cart'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final cartDocs = snapshot.data!.docs;

          if (cartDocs.isEmpty) return _buildEmptyCart();

          final cartItems = cartDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'title': data['title'] ?? 'Untitled',
              'price': (data['price'] ?? 0).toDouble(),
              'quantity': (data['quantity'] ?? 1) as int,
              'image': data['imageUrl'] ?? '',
              'artistId': data['artistId'] ?? '',
              'doc': doc,
            };
          }).toList();

          final totalItems = cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
          final totalPrice = cartItems.fold<double>(
            0,
            (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(item['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${(item['price'] as double).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 20),
                                        onPressed: () => _updateQuantity(item['doc'], -1),
                                      ),
                                      Text(
                                        '${item['quantity']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 20),
                                        onPressed: () => _updateQuantity(item['doc'], 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removeItem(item['doc']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Items: $totalItems', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _continueShopping,
                            child: const Text('Keep Shopping'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            // ✅ Navigates to payment screen and passes data
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentScreen(
                                    cartItems: cartItems,
                                    totalPrice: totalPrice,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Add some products to get started', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _continueShopping,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}
