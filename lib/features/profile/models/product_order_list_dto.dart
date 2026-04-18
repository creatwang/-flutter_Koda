class ProductOrderListDto {
  const ProductOrderListDto({
    required this.items,
    required this.total,
  });

  final List<OrderItemDto> items;
  final int total;

  factory ProductOrderListDto.fromJson(Map<String, dynamic> json) {
    return ProductOrderListDto(
      items: _asMapList(json['items'])
          .map(OrderItemDto.fromJson)
          .toList(growable: false),
      total: _asInt(json['total']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(growable: false),
      'total': total,
    };
  }
}

class OrderItemDto {
  const OrderItemDto({
    this.id,
    this.orderNo,
    this.draftId,
    this.status,
    this.total,
    this.remark,
    required this.product,
    this.createdAt,
    this.piStatus,
    this.user,
    this.companyId,
  });

  final int? id;
  final String? orderNo;
  final int? draftId;
  final int? status;
  final String? total;
  final String? remark;
  final List<OrderDepartmentDto> product;
  final String? createdAt;
  final int? piStatus;
  final OrderUserDto? user;
  final int? companyId;

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      id: _asInt(json['id']),
      orderNo: _asString(json['order_no']),
      draftId: _asInt(json['draft_id']),
      status: _asInt(json['status']),
      total: _asString(json['total']),
      remark: _asString(json['remark']),
      product: _asMapList(json['product'])
          .map(OrderDepartmentDto.fromJson)
          .toList(growable: false),
      createdAt: _asString(json['created_at']),
      piStatus: _asInt(json['pi_status']),
      user: _asMap(json['user']) == null
          ? null
          : OrderUserDto.fromJson(_asMap(json['user'])!),
      companyId: _asInt(json['company_id']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['order_no'] = orderNo;
    data['draft_id'] = draftId;
    data['status'] = status;
    data['total'] = total;
    data['remark'] = remark;
    data['product'] = product
        .map((department) => department.toJson())
        .toList(growable: false);
    data['created_at'] = createdAt;
    data['pi_status'] = piStatus;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['company_id'] = companyId;
    return data;
  }
}

class OrderDepartmentDto {
  const OrderDepartmentDto({
    this.name,
    required this.list,
    this.totalNum,
    this.totalAmount,
  });

  final String? name;
  final List<OrderSpaceDto> list;
  final int? totalNum;
  final double? totalAmount;

  factory OrderDepartmentDto.fromJson(Map<String, dynamic> json) {
    return OrderDepartmentDto(
      name: _asString(json['name']),
      list: _asMapList(json['list'])
          .map(OrderSpaceDto.fromJson)
          .toList(growable: false),
      totalNum: _asInt(json['total_num']),
      totalAmount: _asDouble(json['total_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'list': list.map((space) => space.toJson()).toList(growable: false),
      'total_num': totalNum,
      'total_amount': totalAmount,
    };
  }
}

class OrderSpaceDto {
  const OrderSpaceDto({
    this.name,
    required this.list,
    this.totalNum,
    this.totalAmount,
  });

  final String? name;
  final List<OrderProductLineDto> list;
  final int? totalNum;
  final double? totalAmount;

  factory OrderSpaceDto.fromJson(Map<String, dynamic> json) {
    return OrderSpaceDto(
      name: _asString(json['name']),
      list: _asMapList(json['list'])
          .map(OrderProductLineDto.fromJson)
          .toList(growable: false),
      totalNum: _asInt(json['total_num']),
      totalAmount: _asDouble(json['total_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'list': list.map((line) => line.toJson()).toList(growable: false),
      'total_num': totalNum,
      'total_amount': totalAmount,
    };
  }
}

class OrderProductLineDto {
  const OrderProductLineDto({
    this.id,
    this.auditStatus,
    this.rejectReason,
    this.companyId,
    this.productId,
    this.quantity,
    this.price,
    this.totalPrice,
    this.space,
    this.subName,
    this.mainImage,
    this.name,
    this.unit,
    this.snapshot,
  });

  final int? id;
  final int? auditStatus;
  final String? rejectReason;
  final int? companyId;
  final int? productId;
  final int? quantity;
  final String? price;
  final String? totalPrice;
  final String? space;
  final String? subName;
  final String? mainImage;
  final String? name;
  final String? unit;
  final dynamic snapshot;

  factory OrderProductLineDto.fromJson(Map<String, dynamic> json) {
    return OrderProductLineDto(
      id: _asInt(json['id']),
      auditStatus: _asInt(json['audit_status']),
      rejectReason: _asString(json['reject_reason']),
      companyId: _asInt(json['company_id']),
      productId: _asInt(json['product_id']),
      quantity: _asInt(json['quantity']),
      price: _asString(json['price']),
      totalPrice: _asString(json['total_price']),
      space: _asString(json['space']),
      subName: _asString(json['sub_name']),
      mainImage: _asString(json['main_image']),
      name: _asString(json['name']),
      unit: _asString(json['unit']),
      snapshot: json['snapshot'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['audit_status'] = auditStatus;
    data['reject_reason'] = rejectReason;
    data['company_id'] = companyId;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['price'] = price;
    data['total_price'] = totalPrice;
    data['space'] = space;
    data['sub_name'] = subName;
    data['main_image'] = mainImage;
    data['name'] = name;
    data['unit'] = unit;
    data['snapshot'] = snapshot;
    return data;
  }
}

class OrderUserDto {
  const OrderUserDto({
    this.id,
    this.name,
    this.username,
    this.avatar,
    this.telephone,
    this.email,
    this.createdAt,
    this.nickname,
  });

  final int? id;
  final String? name;
  final String? username;
  final String? avatar;
  final String? telephone;
  final String? email;
  final String? createdAt;
  final String? nickname;

  factory OrderUserDto.fromJson(Map<String, dynamic> json) {
    return OrderUserDto(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      username: _asString(json['username']),
      avatar: _asString(json['avatar']),
      telephone: _asString(json['telephone']),
      email: _asString(json['email']),
      createdAt: _asString(json['created_at']),
      nickname: _asString(json['nickname']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['avatar'] = avatar;
    data['telephone'] = telephone;
    data['email'] = email;
    data['created_at'] = createdAt;
    data['nickname'] = nickname;
    return data;
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return null;
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return value
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
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
