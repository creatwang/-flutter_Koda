import 'package:groe_app_pad/features/product/domain/entities/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
