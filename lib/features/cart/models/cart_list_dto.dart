class CartListDto {
  const CartListDto({
    required this.totalNum,
    required this.totalAmount,
    required this.id,
    required this.name,
    required this.items,
    this.smId = 0,
    this.smItems = const <CartSalesRepDto>[],
  });

  final int totalNum;
  final double totalAmount;
  final int id;
  final String name;
  final List<CartSiteDto> items;
  final int smId;
  final List<CartSalesRepDto> smItems;

  factory CartListDto.fromJson(Map<String, dynamic> json) {
    final totalNum = _asInt(json['total_num']) ?? 0;
    final totalAmount = _asDouble(json['total_amount']) ?? 0;
    final id = _asInt(json['id']) ?? 0;
    final name = (json['name'] ?? '').toString();
    final smId = _asInt(json['sm_id']) ?? 0;
    final smItems = _parseSalesRepList(json['sm_items']);
    final rawItems = (json['items'] as List? ?? const <dynamic>[]);

    final isLegacySiteList = rawItems.any(
      (e) => e is Map && e['cart'] is Map,
    );
    if (isLegacySiteList) {
      final sites = rawItems
          .whereType<Map>()
          .map((e) => CartSiteDto.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
      return CartListDto(
        totalNum: totalNum,
        totalAmount: totalAmount,
        id: id,
        name: name,
        items: sites,
        smId: smId,
        smItems: smItems,
      );
    }

    // 新结构：当前层的 items 就是空间列表，适配为单站点结构供现有 UI 复用。
    final spaces = rawItems
        .whereType<Map>()
        .map((e) => CartSpaceDto.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    final inferredCompanyId =
        _inferCompanyIdFromSpaces(spaces) ??
        _asInt(json['company_id']) ??
        id;
    return CartListDto(
      totalNum: totalNum,
      totalAmount: totalAmount,
      id: id,
      name: name,
      smId: smId,
      smItems: smItems,
      items: <CartSiteDto>[
        CartSiteDto(
          cart: CartSiteSummaryDto(
            items: spaces,
            totalNum: totalNum,
            totalAmount: totalAmount,
          ),
          shopName: name,
          companyId: inferredCompanyId,
          smId: smId,
          smItems: smItems,
        ),
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total_num': totalNum,
      'total_amount': totalAmount,
      'id': id,
      'sm_id': smId,
      'name': name,
      'sm_items': smItems.map((e) => e.toJson()).toList(growable: false),
      'items': items.map((e) => e.toJson()).toList(growable: false),
    };
  }
}

class CartSiteDto {
  const CartSiteDto({
    required this.cart,
    required this.shopName,
    required this.companyId,
    this.smId = 0,
    this.smItems = const <CartSalesRepDto>[],
  });

  final CartSiteSummaryDto cart;
  final String shopName;
  final int companyId;
  final int smId;
  final List<CartSalesRepDto> smItems;

  factory CartSiteDto.fromJson(Map<String, dynamic> json) {
    return CartSiteDto(
      cart: CartSiteSummaryDto.fromJson(
        (json['cart'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
      shopName: (json['shop_name'] ?? '').toString(),
      companyId: _asInt(json['company_id']) ?? 0,
      smId: _asInt(json['sm_id']) ?? 0,
      smItems: _parseSalesRepList(json['sm_items']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cart': cart.toJson(),
      'shop_name': shopName,
      'company_id': companyId,
      'sm_id': smId,
      'sm_items': smItems.map((e) => e.toJson()).toList(growable: false),
    };
  }

  CartSiteDto copyWith({
    CartSiteSummaryDto? cart,
    String? shopName,
    int? companyId,
    int? smId,
    List<CartSalesRepDto>? smItems,
  }) {
    return CartSiteDto(
      cart: cart ?? this.cart,
      shopName: shopName ?? this.shopName,
      companyId: companyId ?? this.companyId,
      smId: smId ?? this.smId,
      smItems: smItems ?? this.smItems,
    );
  }
}

class CartSiteSummaryDto {
  const CartSiteSummaryDto({
    required this.items,
    required this.totalNum,
    required this.totalAmount,
  });

  final List<CartSpaceDto> items;
  final int totalNum;
  final double totalAmount;

  factory CartSiteSummaryDto.fromJson(Map<String, dynamic> json) {
    return CartSiteSummaryDto(
      items: (json['items'] as List? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => CartSpaceDto.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false),
      totalNum: _asInt(json['total_num']) ?? 0,
      totalAmount: _asDouble(json['total_amount']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((e) => e.toJson()).toList(growable: false),
      'total_num': totalNum,
      'total_amount': totalAmount,
    };
  }

  CartSiteSummaryDto copyWith({
    List<CartSpaceDto>? items,
    int? totalNum,
    double? totalAmount,
  }) {
    return CartSiteSummaryDto(
      items: items ?? this.items,
      totalNum: totalNum ?? this.totalNum,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class CartSpaceDto {
  const CartSpaceDto({
    required this.name,
    required this.key,
    required this.list,
    required this.totalNum,
    required this.totalAmount,
  });

  final String name;
  final String key;
  final List<CartProductDto> list;
  final int totalNum;
  final double totalAmount;

  factory CartSpaceDto.fromJson(Map<String, dynamic> json) {
    return CartSpaceDto(
      name: (json['name'] ?? '').toString(),
      key: (json['key'] ?? '').toString(),
      list: (json['list'] as List? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => CartProductDto.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false),
      totalNum: _asInt(json['total_num']) ?? 0,
      totalAmount: _asDouble(json['total_amount']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'key': key,
      'list': list.map((e) => e.toJson()).toList(growable: false),
      'total_num': totalNum,
      'total_amount': totalAmount,
    };
  }

  CartSpaceDto copyWith({
    String? name,
    String? key,
    List<CartProductDto>? list,
    int? totalNum,
    double? totalAmount,
  }) {
    return CartSpaceDto(
      name: name ?? this.name,
      key: key ?? this.key,
      list: list ?? this.list,
      totalNum: totalNum ?? this.totalNum,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class CartProductDto {
  const CartProductDto({
    required this.id,
    required this.selected,
    required this.productId,
    required this.productNum,
    required this.subIndex,
    required this.subName,
    required this.space,
    required this.status,
    required this.price,
    required this.mainImage,
    required this.name,
    required this.unit,
    required this.pdmsId,
    required this.uniqid,
    required this.isCollect,
    required this.avgComment,
    required this.remark,
    this.companyId = 0,
    this.shopDepartmentId = 0,
    this.smId = 0,
    this.subPrice = 0,
    this.combProductList = const <dynamic>[],
    this.matchCombinations = const <dynamic>[],
  });

  final int id;
  final int selected;
  final int productId;
  final int productNum;
  final String subIndex;
  final String subName;
  final String space;
  final int status;
  final double price;
  final String mainImage;
  final String name;
  final String unit;
  final int pdmsId;
  final String uniqid;
  final bool isCollect;
  final String avgComment;
  final String remark;
  final int companyId;
  final int shopDepartmentId;
  final int smId;
  final double subPrice;
  final List<dynamic> combProductList;
  final List<dynamic> matchCombinations;

  bool get isSelected => selected == 1;

  factory CartProductDto.fromJson(Map<String, dynamic> json) {
    return CartProductDto(
      id: _asInt(json['id']) ?? 0,
      selected: _asInt(json['selected']) ?? 0,
      productId: _asInt(json['product_id']) ?? 0,
      productNum: _asInt(json['product_num']) ?? 0,
      subIndex: (json['sub_index'] ?? '').toString(),
      subName: (json['sub_name'] ?? '').toString(),
      space: (json['space'] ?? '').toString(),
      status: _asInt(json['status']) ?? 0,
      price: _asDouble(json['price']) ?? 0,
      mainImage: (json['main_image'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      pdmsId: _asInt(json['pdms_id']) ?? 0,
      uniqid: (json['uniqid'] ?? '').toString(),
      isCollect: json['is_collect'] == true || json['is_collect'] == 1,
      avgComment: (json['avg_comment'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
      companyId: _asInt(json['company_id']) ?? 0,
      shopDepartmentId: _asInt(json['shop_department_id']) ?? 0,
      smId: _asInt(json['sm_id']) ?? 0,
      subPrice: _asDouble(json['sub_price']) ?? 0,
      combProductList:
          (json['comb_product_list'] as List? ?? const <dynamic>[])
              .toList(growable: false),
      matchCombinations:
          (json['match_combinations'] as List? ?? const <dynamic>[])
              .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'selected': selected,
      'product_id': productId,
      'product_num': productNum,
      'sub_index': subIndex,
      'sub_name': subName,
      'space': space,
      'status': status,
      'price': price,
      'main_image': mainImage,
      'name': name,
      'unit': unit,
      'pdms_id': pdmsId,
      'uniqid': uniqid,
      'is_collect': isCollect,
      'avg_comment': avgComment,
      'remark': remark,
      'company_id': companyId,
      'shop_department_id': shopDepartmentId,
      'sm_id': smId,
      'sub_price': subPrice,
      'comb_product_list': combProductList,
      'match_combinations': matchCombinations,
    };
  }

  CartProductDto copyWith({int? selected, int? productNum, String? remark}) {
    return CartProductDto(
      id: id,
      selected: selected ?? this.selected,
      productId: productId,
      productNum: productNum ?? this.productNum,
      subIndex: subIndex,
      subName: subName,
      space: space,
      status: status,
      price: price,
      mainImage: mainImage,
      name: name,
      unit: unit,
      pdmsId: pdmsId,
      uniqid: uniqid,
      isCollect: isCollect,
      avgComment: avgComment,
      remark: remark ?? this.remark,
      companyId: companyId,
      shopDepartmentId: shopDepartmentId,
      smId: smId,
      subPrice: subPrice,
      combProductList: combProductList,
      matchCombinations: matchCombinations,
    );
  }
}

class CartSalesRepDto {
  const CartSalesRepDto({
    required this.id,
    required this.name,
    required this.avatar,
    required this.deptName,
    this.telephone,
  });

  final int id;
  final String name;
  final String avatar;
  final String deptName;
  final String? telephone;

  factory CartSalesRepDto.fromJson(Map<String, dynamic> json) {
    return CartSalesRepDto(
      id: _asInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      deptName: (json['deptName'] ?? '').toString(),
      telephone: json['telephone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'avatar': avatar,
      'deptName': deptName,
      'telephone': telephone,
    };
  }
}

List<CartSalesRepDto> _parseSalesRepList(dynamic raw) {
  final list = raw as List? ?? const <dynamic>[];
  return list
      .whereType<Map>()
      .map((e) => CartSalesRepDto.fromJson(e.cast<String, dynamic>()))
      .toList(growable: false);
}

int? _inferCompanyIdFromSpaces(List<CartSpaceDto> spaces) {
  for (final space in spaces) {
    for (final item in space.list) {
      if (item.companyId > 0) return item.companyId;
    }
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
