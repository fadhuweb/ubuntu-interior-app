// cart_item.dart
class CartItem {
  final String id;
  final String name;
  final String image;
  final double price;
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.quantity = 1,
  });
}
