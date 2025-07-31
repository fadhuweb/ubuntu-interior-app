import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_artwork_page.dart';
import 'manage_listings_page.dart';
import 'order_page.dart';
import 'settings_page.dart';

class ArtistHomePage extends StatelessWidget {
  const ArtistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final artistId = FirebaseAuth.instance.currentUser!.uid;

    final usersRef = FirebaseFirestore.instance.collection('users').doc(artistId);

    final artworksRef = FirebaseFirestore.instance
        .collection('artworks')
        .where('createdBy', isEqualTo: artistId);

    final itemStatusRef = FirebaseFirestore.instance
        .collectionGroup('itemStatus')
        .where('artistId', isEqualTo: artistId)
        .where('status', whereIn: ['Pending', 'Processing', 'Shipped']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE95420),
        title: const Text('Artist Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            FutureBuilder<DocumentSnapshot>(
              future: usersRef.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildErrorCard();
                }

                final name = snapshot.data!.get('name') ?? 'Artist';

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE95420), Color(0xFFFF6B35)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withAlpha(77),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome back!',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Ready to create something amazing?',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(230))),
                          ],
                        ),
                      ),
                      const Icon(Icons.palette, color: Colors.white, size: 40),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: artworksRef.snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return _buildStatCard('Total Artworks', '$count',
                          Icons.image, const Color(0xFFE95420));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: itemStatusRef.snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return _buildStatCard('Active Orders', '$count',
                          Icons.shopping_cart, const Color(0xFF772953));
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Projects',
                    Icons.folder_open,
                    const Color(0xFFE95420),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ManageListingsPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Orders',
                    Icons.receipt_long,
                    const Color(0xFF772953),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ArtistOrderPage()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // CTA to Add New Artwork
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UploadArtworkPage()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Upload New Artwork'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE95420),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color,
      VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Could not load artist name.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
