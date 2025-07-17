import 'package:flutter/material.dart';
import 'package:ubuntu_app/screens/artist/upload_artwork_page.dart';

class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});

  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  final List<Map<String, String>> dummyListings = [
    {
      'title': 'Sunset Over Hills',
      'price': '50.00',
      'image':
      'https://images.unsplash.com/photo-1504198453319-5ce911bafcde?fit=crop&w=800&q=80'
    },
    {
      'title': 'Abstract Lines',
      'price': '40.00',
      'image':
      'https://images.unsplash.com/photo-1602526212863-6fa6a7580ff1?fit=crop&w=800&q=80'
    },
    {
      'title': 'Ocean Dream',
      'price': '60.00',
      'image':
      'https://images.unsplash.com/photo-1519222970733-f546218fa6d1?fit=crop&w=800&q=80'
    },
  ];

  void _deleteItem(int index) {
    setState(() {
      dummyListings.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing deleted')),
    );
  }

  void _editItem(int index) {
    // Navigate to upload page with existing data for editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadArtworkPage(
          // You can pass the existing data here if UploadArtworkPage supports editing
          // existingData: dummyListings[index],
        ),
      ),
    );
  }

  void _navigateToUploadPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadArtworkPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage My Listings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: dummyListings.isEmpty
          ? const Center(child: Text('No listings to display.'))
          : ListView.builder(
        itemCount: dummyListings.length,
        itemBuilder: (context, index) {
          final item = dummyListings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['image']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                  ),
                ),
              ),
              title: Text(item['title']!),
              subtitle: Text('\$${item['price']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editItem(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUploadPage,
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
        tooltip: 'Upload New Artwork',
      ),
    );
  }
}
