class OrderModel {
  final String customerName;
  final String artworkTitle;
  final int quantity;
  final double totalPrice;
  final String status;

  OrderModel({
    required this.customerName,
    required this.artworkTitle,
    required this.quantity,
    required this.totalPrice,
    required this.status,
  });
}

// Sample mock orders
List<OrderModel> sampleOrders = [
  OrderModel(
    customerName: 'Alice Johnson',
    artworkTitle: 'Sunset Glow',
    quantity: 1,
    totalPrice: 150.0,
    status: 'Pending',
  ),
  OrderModel(
    customerName: 'Bob Smith',
    artworkTitle: 'Abstract Blue',
    quantity: 2,
    totalPrice: 300.0,
    status: 'Shipped',
  ),
];
