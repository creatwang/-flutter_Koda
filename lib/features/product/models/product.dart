class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.price,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final String image;
  final double price;
}
