class Artwork {
  final String title;
  final String description;
  final String price;
  final String imagePath;

  Artwork({
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
  });
}

List<Artwork> localArtworks = []; // Global list of uploaded artworks
