import 'package:groe_app_pad/features/product/models/product_item.dart';

class ProductFavDto {
  ProductFavDto({
    required this.id,
    required this.productId,
    required this.isCollect,
    required this.product,
  });

  final int id;
  final int productId;
  final bool isCollect;
  final ProductFavProductDto product;

  factory ProductFavDto.fromJson(Map<String, dynamic> json) {
    final nested = _asMap(json['product']);
    return ProductFavDto(
      id: _asInt(json['id']),
      productId: _asInt(json['product_id']),
      isCollect: _asBool(json['is_collect']),
      product: ProductFavProductDto.fromJson(
        nested ?? json,
      ),
    );
  }
}

class ProductFavProductDto {
  ProductFavProductDto({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.unit,
    required this.mainImage,
    required this.price,
    required this.maxPrice,
    required this.categoryName,
  });

  final int id;
  final num categoryId;
  final String name;
  final String unit;
  final String mainImage;
  final double price;
  final double maxPrice;
  final String categoryName;

  factory ProductFavProductDto.fromJson(Map<String, dynamic> json) {
    return ProductFavProductDto(
      id: _asInt(json['id']),
      categoryId: _asNum(json['category_id']),
      name: _asString(json['name']),
      unit: _asString(json['unit']),
      mainImage: _asString(json['main_image']),
      price: _asDouble(json['price']),
      maxPrice: _asDouble(json['max_price']),
      categoryName: _asString(json['category_name']),
    );
  }
}

extension ProductFavDtoX on ProductFavDto {
  ProductItem toModel() {
    final resolvedId = product.id != 0 ? product.id : productId;
    return ProductItem(
      id: resolvedId,
      categoryName: product.categoryName,
      categoryId: product.categoryId,
      name: product.name,
      unit: product.unit,
      maxPrice: product.maxPrice,
      price: product.price,
      isHot: '0',
      mainImage: product.mainImage,
      isCollect: true,
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

num _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String _asString(dynamic value) => value?.toString() ?? '';

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }
  return false;
}
