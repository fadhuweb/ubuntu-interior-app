import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageListingsPage extends StatelessWidget {
  const ManageListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final artistId = FirebaseAuth.instance.currentUser!.uid;
    final artworksRef = FirebaseFirestore.instance
        .collection('artworks')
        .where('createdBy', isEqualTo: artistId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE95420),
        title: const Text('Manage Listings',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: artworksRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('You have no artworks listed.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                child: ListTile(
                  leading: data['imageUrl'] != null
                      ? Image.network(data['imageUrl'], width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(data['title'] ?? 'Untitled'),
                  subtitle: Text('\$${(data['price'] ?? 0).toString()}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditSheet(context, docId, data);
                      } else if (value == 'delete') {
                        _confirmDelete(context, docId);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
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

  void _confirmDelete(BuildContext context, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Artwork'),
        content: const Text('Are you sure you want to delete this artwork?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('artworks').doc(docId).delete();
    }
  }

  void _showEditSheet(BuildContext context, String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title']);
    final descController = TextEditingController(text: data['description']);
    final priceController = TextEditingController(text: (data['price'] ?? '').toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Artwork', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE95420)),
              onPressed: () async {
                final newTitle = titleController.text.trim();
                final newDesc = descController.text.trim();
                final newPrice = double.tryParse(priceController.text.trim()) ?? 0;

               await FirebaseFirestore.instance.collection('artworks').doc(docId).update({
  'title': newTitle,
  'description': newDesc,
  'price': newPrice,
});

if (!context.mounted) return;
Navigator.pop(context);

              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
