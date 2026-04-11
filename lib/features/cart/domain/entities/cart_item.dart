import 'package:groe_app_pad/features/product/models/product_item.dart';

class CartItem {
  const CartItem({
    required this.productItem,
    required this.quantity,
  });

  final ProductItem productItem;
  final int quantity;

  CartItem copyWith({
    ProductItem? productItem,
    int? quantity,
  }) {
    return CartItem(
      productItem: productItem ?? this.productItem,
      quantity: quantity ?? this.quantity,
    );
  }
}
