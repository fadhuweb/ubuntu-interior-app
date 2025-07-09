import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> products = const [
    {
      'name': 'Luxurious Kente',
      'image': 'https://images.pexels.com/photos/31730273/pexels-photo-31730273.jpeg',
      'price': 45.00,
      'originalPrice': 60.00,
      'rating': 4.8,
      'reviews': 127,
      'description': 'Handwoven traditional Kente cloth with intricate patterns',
      'badge': 'Best Seller',
      'category': 'Textiles',
      'colors': ['#FFD700', '#8B4513', '#006400'],
    },
    {
      'name': 'Beaded Maasai Necklace',
      'image': 'https://images.pexels.com/photos/2050999/pexels-photo-2050999.jpeg',
      'price': 75.00,
      'originalPrice': null,
      'rating': 4.7,
      'reviews': 54,
      'description': 'Traditional Maasai handcrafted colorful bead necklace',
      'badge': 'Exclusive',
      'category': 'Jewelry',
      'colors': ['#FF4500', '#32CD32', '#FFD700'],
    },
    {
      'name': 'African Tribal Mask',
      'image': 'https://images.pexels.com/photos/1704120/pexels-photo-1704120.jpeg',
      'price': 120.00,
      'originalPrice': 150.00,
      'rating': 4.9,
      'reviews': 80,
      'description': 'Hand-carved wooden mask from West African tribes',
      'badge': 'Premium',
      'category': 'Art',
      'colors': ['#8B4513', '#A0522D', '#CD853F'],
    },
    {
      'name': 'Woven Basket Set',
      'image': 'https://images.pexels.com/photos/1761043/pexels-photo-1761043.jpeg',
      'price': 55.00,
      'originalPrice': null,
      'rating': 4.6,
      'reviews': 110,
      'description': 'Handwoven baskets made from natural fibers',
      'badge': 'Popular',
      'category': 'Crafts',
      'colors': ['#DEB887', '#F5F5DC', '#A0522D'],
    },
  ];

  final List<String> categories = ['All', 'Textiles', 'Jewelry', 'Art', 'Crafts'];
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == 'All'
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildCategoryFilter(),
          _buildProductGrid(filteredProducts),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      floating: true,
      pinned: true,
      snap: false,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: const Text(
        'Products',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedCategory == 'All' ? products.length : products.where((p) => p['category'] == selectedCategory).length} Products',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Optional: Add filter logic here
                    },
                    icon: const Icon(Icons.tune, size: 18, color: Color(0xFF666666)),
                    label: const Text(
                      'Filter',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _CategoryChip(
                      label: category,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> filteredProducts) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = filteredProducts[index];
            return _ProductCard(product: product);
          },
          childCount: filteredProducts.length,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          )),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF1A1A1A),
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 14),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final price = product['price'] as double;
    final originalPrice = product['originalPrice'] as double?;
    final badge = product['badge'] as String?;
    final colors = product['colors'] as List<String>?;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // You can add navigation to product detail here
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product['image'],
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product['name'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  if (originalPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${product['rating']} (${product['reviews']} reviews)',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (colors != null)
                SizedBox(
                  height: 20,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final colorHex = colors[index];
                      final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
                      return Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ProductsPage(),
    debugShowCheckedModeBanner: false,
  ));
}
