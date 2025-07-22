import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatelessWidget {
  final String title;
  final String artist; // artist UID
  final String description;
  final String imageUrl;
  final double price;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.artist,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  // Fetch artist name from Firestore using UID
  Future<String> fetchArtistName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(artist).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Unknown Artist';
      } else {
        return 'Unknown Artist';
      }
    } catch (e) {
      return 'Unknown Artist';
    }
  }

  // Add to cart logic
  Future<void> addToCart(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to add to cart")),
        );
        return;
      }

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final existing = await cartRef
          .where('artworkTitle', isEqualTo: title)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final currentQty = doc['quantity'] ?? 1;
        await cartRef.doc(doc.id).update({'quantity': currentQty + 1});
      } else {
        await cartRef.add({
          'artworkTitle': title,
          'artistId': artist,
          'description': description,
          'imageUrl': imageUrl,
          'price': price,
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to cart")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add to cart: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchArtistName(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final artistName = snapshot.data ?? 'Unknown Artist';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Product Detail"),
            backgroundColor: Colors.brown[700],
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Artist Profile
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.brown,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artistName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Blending native passion with modern African stories.",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text("Follow"),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.brown.shade100),
                  ),
                  child: Text(
                    "“$description”",
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Spacer(),

                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => addToCart(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Add to Cart"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
