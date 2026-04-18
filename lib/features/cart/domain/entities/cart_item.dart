import 'package:groe_app_pad/features/product/models/product_item.dart';

class CartItem {
  const CartItem({required this.productItem, required this.quantity});

  final ProductItem productItem;
  final int quantity;

  CartItem copyWith({ProductItem? productItem, int? quantity}) {
    return CartItem(
      productItem: productItem ?? this.productItem,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productItem: ProductItem.fromJson(
        (json['product_item'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      quantity: _asInt(json['quantity']) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'product_item': productItem.toJson(),
      'quantity': quantity,
    };
  }
}

int? _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
