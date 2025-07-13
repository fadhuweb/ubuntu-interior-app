import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'shared_cart.dart';
import 'cart_item.dart';

// Product Model
class Product {
  final String name, image, description, category;
  final double price;

  Product({
    required this.name,
    required this.image,
    required this.description,
    required this.category,
    required this.price,
  });
}

// All products list
final List<Product> allProducts = [
  Product(name: "Abstract Painting", image: "assets/images/art1.jpg", description: "A beautiful abstract painting.", category: "Art", price: 120.0),
  Product(name: "Modern Sculpture", image: "assets/images/art2.jpg", description: "Contemporary sculpture artwork.", category: "Art", price: 250.0),
  Product(name: "Ceramic Vase", image: "assets/images/ceramic1.jpg", description: "Hand-crafted ceramic vase.", category: "Ceramic", price: 80.0),
  Product(name: "Ceramic Plate Set", image: "assets/images/ceramic2.jpg", description: "Set of 4 decorative plates.", category: "Ceramic", price: 60.0),
  Product(name: "Pottery Bowl", image: "assets/images/pottery1.jpg", description: "Rustic handmade bowl.", category: "Pottery", price: 45.0),
  Product(name: "Clay Jug", image: "assets/images/pottery2.jpg", description: "Traditional clay jug.", category: "Pottery", price: 55.0),
  Product(name: "Woven Blanket", image: "assets/images/textile1.jpg", description: "Warm and cozy woven blanket.", category: "Textile", price: 70.0),
  Product(name: "Handmade Rug", image: "assets/images/textile2.jpg", description: "Colorful handmade rug.", category: "Textile", price: 110.0),
];

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  void addToCart(Product product) {
    final existing = cartItems.firstWhere(
          (item) => item.name == product.name,
      orElse: () => CartItem(
        name: product.name,
        image: product.image,
        category: product.category,
        price: product.price,
        quantity: 0,
        id: '',
      ),
    );

    setState(() {
      if (existing.quantity > 0) {
        existing.quantity++;
      } else {
        cartItems.add(CartItem(
          name: product.name,
          image: product.image,
          category: product.category,
          price: product.price,
          quantity: 1,
          id: '',
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} added to cart")),
    );
  }

  int get totalCartItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$totalCartItems',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: allProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final product = allProducts[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(product.category, style: const TextStyle(color: Colors.grey)),
                      Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => addToCart(product),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text("Add", style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                                );
                              },
                              child: const Text("View", style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Detail View Page
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              product.image,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 100),
            ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(product.category, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontSize: 20)),
            const SizedBox(height: 16),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(product.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final existing = cartItems.firstWhere(
                        (item) => item.name == product.name,
                    orElse: () => CartItem(
                      name: product.name,
                      image: product.image,
                      category: product.category,
                      price: product.price,
                      quantity: 0,
                      id: '',
                    ),
                  );

                  if (existing.quantity > 0) {
                    existing.quantity++;
                  } else {
                    cartItems.add(CartItem(
                      name: product.name,
                      image: product.image,
                      category: product.category,
                      price: product.price,
                      quantity: 1,
                      id: '',
                    ));
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${product.name} added to cart")),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Add to Cart"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
