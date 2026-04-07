import 'package:groe_app_pad/features/order/domain/entities/order_summary.dart';

class OrderItemDto {
  const OrderItemDto({
    required this.productId,
    required this.quantity,
  });

  final int productId;
  final int quantity;

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
    );
  }
}

class OrderDto {
  const OrderDto({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  final int id;
  final int userId;
  final DateTime date;
  final List<OrderItemDto> products;

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final products = (json['products'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItemDto.fromJson)
        .toList(growable: false);
    return OrderDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      products: products,
    );
  }
}

extension OrderDtoX on OrderDto {
  OrderSummary toDomain() {
    final qty = products.fold<int>(0, (sum, e) => sum + e.quantity);
    return OrderSummary(id: id, userId: userId, date: date, totalQuantity: qty);
  }
}
