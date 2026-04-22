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
  final num categoryId;
  final String name;
  final String unit;
  final String mainImage;
  final String isHot;
  final bool isCollect;
  final double maxPrice;
  final double price;

  /// 与后端 `is_hot` 一致；**严格等于 1** 时展示「NEW COLLECTION」等标识。
  bool get showsNewCollectionTag => int.tryParse(isHot.trim()) == 1;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: _asInt(json['id']) ?? 0,
      categoryName: (json['category_name'] ?? '').toString(),
      categoryId: _asNum(json['category_id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      maxPrice: _asDouble(json['max_price']) ?? 0,
      price: _asDouble(json['price']) ?? 0,
      isHot: (json['is_hot'] ?? '').toString(),
      mainImage: (json['main_image'] ?? '').toString(),
      isCollect: _asBool(json['is_collect']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category_name': categoryName,
      'category_id': categoryId,
      'name': name,
      'unit': unit,
      'max_price': maxPrice,
      'price': price,
      'is_hot': isHot,
      'main_image': mainImage,
      'is_collect': isCollect,
    };
  }
}

int? _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

num? _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool _asBool(dynamic value) {
  if (value == true || value == 1 || value == '1') return true;
  if (value == false || value == 0 || value == '0') return false;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}
