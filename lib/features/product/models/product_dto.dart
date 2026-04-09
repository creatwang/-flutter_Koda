import 'package:groe_app_pad/features/product/models/product.dart';

class ProductDto {
  const ProductDto({
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

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    return ProductDto(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      image: json['thumbnail']?.toString() ??
          json['image']?.toString() ??
          (images.isNotEmpty ? images.first : ''),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

extension ProductDtoX on ProductDto {
  Product toModel() {
    return Product(
      id: id,
      title: title,
      description: description,
      category: category,
      image: image,
      price: price,
    );
  }
}
