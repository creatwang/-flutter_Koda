class ProductCartDto {
  ProductCartDto({
    this.totalNum,
    this.totalAmount,
    this.id,
    this.name,
    this.items = const <ProductCartShopItemDto>[],
  });

  factory ProductCartDto.fromDio(dynamic data) {
    final json = _asMap(data) ?? <String, dynamic>{};
    if (json.containsKey('data')) {
      final wrapped = _asMap(json['data']);
      if (wrapped != null) {
        return ProductCartDto.fromJson(wrapped);
      }
    }
    return ProductCartDto.fromJson(json);
  }

  factory ProductCartDto.fromJson(Map<String, dynamic> json) {
    return ProductCartDto(
      totalNum: _asInt(json['total_num']),
      totalAmount: _asDouble(json['total_amount']),
      id: _asInt(json['id']),
      name: _asString(json['name']),
      items: _asList(json['items'])
          .map((item) => ProductCartShopItemDto.fromJson(item))
          .toList(growable: false),
    );
  }

  final int? totalNum;
  final double? totalAmount;
  final int? id;
  final String? name;
  final List<ProductCartShopItemDto> items;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total_num': totalNum,
      'total_amount': totalAmount,
      'id': id,
      'name': name,
      'items': items.map((v) => v.toJson()).toList(growable: false),
    };
  }
}

class ProductCartShopItemDto {
  ProductCartShopItemDto({
    this.cart,
    this.shopName,
    this.companyId,
  });

  factory ProductCartShopItemDto.fromJson(Map<String, dynamic> json) {
    return ProductCartShopItemDto(
      cart: _asMap(json['cart']) == null
          ? null
          : ProductCartSectionDto.fromJson(_asMap(json['cart'])!),
      shopName: _asString(json['shop_name']),
      companyId: _asInt(json['company_id']),
    );
  }

  final ProductCartSectionDto? cart;
  final String? shopName;
  final int? companyId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cart': cart?.toJson(),
      'shop_name': shopName,
      'company_id': companyId,
    };
  }
}

class ProductCartSectionDto {
  ProductCartSectionDto({
    this.items = const <ProductCartGroupDto>[],
    this.totalNum,
    this.totalAmount,
  });

  factory ProductCartSectionDto.fromJson(Map<String, dynamic> json) {
    return ProductCartSectionDto(
      items: _asList(json['items'])
          .map((item) => ProductCartGroupDto.fromJson(item))
          .toList(growable: false),
      totalNum: _asInt(json['total_num']),
      totalAmount: _asDouble(json['total_amount']),
    );
  }

  final List<ProductCartGroupDto> items;
  final int? totalNum;
  final double? totalAmount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((v) => v.toJson()).toList(growable: false),
      'total_num': totalNum,
      'total_amount': totalAmount,
    };
  }
}

class ProductCartGroupDto {
  ProductCartGroupDto({
    this.name,
    this.key,
    this.list = const <ProductCartLineItemDto>[],
    this.totalNum,
    this.totalAmount,
  });

  factory ProductCartGroupDto.fromJson(Map<String, dynamic> json) {
    return ProductCartGroupDto(
      name: _asString(json['name']),
      key: _asString(json['key']),
      list: _asList(json['list'])
          .map((item) => ProductCartLineItemDto.fromJson(item))
          .toList(growable: false),
      totalNum: _asInt(json['total_num']),
      totalAmount: _asDouble(json['total_amount']),
    );
  }

  final String? name;
  final String? key;
  final List<ProductCartLineItemDto> list;
  final int? totalNum;
  final double? totalAmount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'key': key,
      'list': list.map((v) => v.toJson()).toList(growable: false),
      'total_num': totalNum,
      'total_amount': totalAmount,
    };
  }
}

class ProductCartLineItemDto {
  ProductCartLineItemDto({
    this.id,
    this.selected,
    this.productId,
    this.productNum,
    this.subIndex,
    this.subName,
    this.space,
    this.combProductList = const <dynamic>[],
    this.subPrice,
    this.status,
    this.price,
    this.mainImage,
    this.name,
    this.unit,
    this.pdmsId,
    this.uniqid,
    this.isCollect,
    this.avgComment,
    this.matchCombinations = const <dynamic>[],
  });

  factory ProductCartLineItemDto.fromJson(Map<String, dynamic> json) {
    return ProductCartLineItemDto(
      id: _asInt(json['id']),
      selected: _asInt(json['selected']),
      productId: _asInt(json['product_id']),
      productNum: _asInt(json['product_num']),
      subIndex: _asString(json['sub_index']),
      subName: _asString(json['sub_name']),
      space: _asString(json['space']),
      combProductList: _asRawList(json['comb_product_list']),
      subPrice: _asDouble(json['sub_price']),
      status: _asInt(json['status']),
      price: _asDouble(json['price']),
      mainImage: _asString(json['main_image']),
      name: _asString(json['name']),
      unit: _asString(json['unit']),
      pdmsId: _asInt(json['pdms_id']),
      uniqid: _asString(json['uniqid']),
      isCollect: _asBool(json['is_collect']),
      avgComment: _asString(json['avg_comment']),
      matchCombinations: _asRawList(json['match_combinations']),
    );
  }

  final int? id;
  final int? selected;
  final int? productId;
  final int? productNum;
  final String? subIndex;
  final String? subName;
  final String? space;
  final List<dynamic> combProductList;
  final double? subPrice;
  final int? status;
  final double? price;
  final String? mainImage;
  final String? name;
  final String? unit;
  final int? pdmsId;
  final String? uniqid;
  final bool? isCollect;
  final String? avgComment;
  final List<dynamic> matchCombinations;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'selected': selected,
      'product_id': productId,
      'product_num': productNum,
      'sub_index': subIndex,
      'sub_name': subName,
      'space': space,
      'comb_product_list': combProductList,
      'sub_price': subPrice,
      'status': status,
      'price': price,
      'main_image': mainImage,
      'name': name,
      'unit': unit,
      'pdms_id': pdmsId,
      'uniqid': uniqid,
      'is_collect': isCollect,
      'avg_comment': avgComment,
      'match_combinations': matchCombinations,
    };
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry('$k', v));
  return null;
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return value
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

List<dynamic> _asRawList(dynamic value) {
  if (value is! Iterable) return const <dynamic>[];
  return List<dynamic>.from(value);
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final normalized = '$value'.trim();
  if (normalized.isEmpty || normalized == 'null') return null;
  return normalized;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = '$value'.toLowerCase().trim();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}
