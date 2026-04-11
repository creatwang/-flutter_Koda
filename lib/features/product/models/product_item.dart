class ProductItem {
  const ProductItem({
    required this.id,
    required this.categoryName,
    required this.categoryId,
    required this.name,
    required this.unit,
    required this.maxPrice,
    required this.price,
    required this.isHot,
    required this.mainImage,
    required this.isCollect,
  });

  final int id;
  final String categoryName;
  final String categoryId;
  final String name;
  final String unit;
  final String mainImage;
  final String isHot;
  final bool isCollect;
  final String maxPrice;
  final double price;
}
