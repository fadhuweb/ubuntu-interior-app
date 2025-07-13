class Product {
  final String title;
  final String artist;
  final String description;
  final String imageUrl;
  final double price;
  final List<String> categories;

  Product({
    required this.title,
    required this.artist,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.categories = const ['Art'],
    required name,
    required image,
  });
}
