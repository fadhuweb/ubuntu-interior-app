import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> loadSampleData() async {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Create sample users
  final userRef = await db.collection('users').add({
    'email': 'zola@example.com',
    'name': 'Zola Moyo',
    'role': 'artist',
    'profileImage': '',
    'bio': 'Interior designer blending modern decor with African heritage',
    'createdAt': Timestamp.now(),
  });

  // Create sample categories
  await db.collection('categories').add({
    'name': 'Textiles',
    'imageUrl': 'https://via.placeholder.com/150',
  });

  // Create sample artwork
  final artworkRef = await db.collection('artworks').add({
    'title': 'Zulu Beaded Cloth',
    'description': 'Handcrafted bead textile representing Zulu culture.',
    'price': 120.0,
    'category': 'Textiles',
    'imageUrl': 'https://via.placeholder.com/400',
    'createdBy': userRef,
    'createdAt': Timestamp.now(),
  });

  // Create a sample order
  await db.collection('orders').add({
    'userId': userRef,
    'items': [
      {'artworkId': artworkRef.id, 'quantity': 1} 
    ],
    'totalAmount': 120.0,
    'status': 'pending',
    'shippingAddress': {
      'fullName': 'Zola Moyo',
      'address': '123 Heritage Lane',
      'city': 'Nairobi',
      'postalCode': '00100',
      'country': 'Kenya',
    },
    'createdAt': Timestamp.now(),
  });

  print('Sample data added successfully');
}
