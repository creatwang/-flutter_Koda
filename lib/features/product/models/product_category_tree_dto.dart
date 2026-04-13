class ProductCategoryTreeDto {
  const ProductCategoryTreeDto({
    this.id,
    this.image,
    this.parentId,
    this.name,
    this.type,
    this.children = const <ProductCategoryTreeDto>[],
  });

  final int? id;
  final String? image;
  final int? parentId;
  final String? name;
  final String? type;
  final List<ProductCategoryTreeDto> children;

  factory ProductCategoryTreeDto.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return ProductCategoryTreeDto(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      image: json['image']?.toString(),
      parentId: json['parent_id'] is num ? (json['parent_id'] as num).toInt() : null,
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      children: rawChildren is List
          ? rawChildren
              .whereType<Map>()
              .map((e) => ProductCategoryTreeDto.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <ProductCategoryTreeDto>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'parent_id': parentId,
      'name': name,
      'type': type,
      'children': children.map((e) => e.toJson()).toList(growable: false),
    };
  }
}
