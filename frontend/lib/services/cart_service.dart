// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../cart_item.dart';

// class CartService {
//   static final _firestore = FirebaseFirestore.instance;
//   static final _auth = FirebaseAuth.instance;

//   static String get uid => _auth.currentUser!.uid;

//   static CollectionReference get _cartRef =>
//       _firestore.collection('users').doc(uid).collection('cart');

//   static Future<void> addToCart(CartItem item) async {
//     final doc = _cartRef.doc(item.id);

//     final docSnapshot = await doc.get();

//     if (docSnapshot.exists) {
//       // If item exists, increment quantity
//       await doc.update({
//         'quantity': FieldValue.increment(1),
//       });
//     } else {
//       // If item doesn't exist, create it
//       await doc.set({
//         'id': item.id,
//         'name': item.name,
//         'image': item.image,
//         'price': item.price,
//         'category': item.category,
//         'quantity': item.quantity,
//       });
//     }
//   }

//   static Future<void> updateQuantity(String itemId, int quantity) async {
//     if (quantity <= 0) {
//       await _cartRef.doc(itemId).delete();
//     } else {
//       await _cartRef.doc(itemId).update({'quantity': quantity});
//     }
//   }

//   static Future<void> removeItem(String itemId) async {
//     await _cartRef.doc(itemId).delete();
//   }

//   static Stream<List<CartItem>> getCartItems() {
//     return _cartRef.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return CartItem(
//           id: data['id'],
//           name: data['name'],
//           image: data['image'],
//           price: data['price'],
//           category: data['category'],
//           quantity: data['quantity'],
//         );
//       }).toList();
//     });
//   }
// }
