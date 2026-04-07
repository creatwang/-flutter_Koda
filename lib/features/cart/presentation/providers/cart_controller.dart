import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/cart/domain/entities/cart_item.dart';
import 'package:groe_app_pad/features/product/models/product.dart';

final cartControllerProvider =
    AsyncNotifierProvider<CartController, List<CartItem>>(CartController.new);

class CartController extends AsyncNotifier<List<CartItem>> {
  @override
  FutureOr<List<CartItem>> build() => [];

  void addProduct(Product product) {
    final current = state.asData?.value ?? [];
    final idx = current.indexWhere((e) => e.product.id == product.id);
    if (idx == -1) {
      state = AsyncData([...current, CartItem(product: product, quantity: 1)]);
      return;
    }

    final updated = [...current];
    updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
    state = AsyncData(updated);
  }

  void removeProduct(int productId) {
    final current = state.asData?.value ?? [];
    state = AsyncData(current.where((e) => e.product.id != productId).toList());
  }

  void decrementProduct(int productId) {
    final current = state.asData?.value ?? [];
    final idx = current.indexWhere((e) => e.product.id == productId);
    if (idx == -1) return;
    final item = current[idx];
    if (item.quantity <= 1) {
      removeProduct(productId);
      return;
    }
    final updated = [...current];
    updated[idx] = item.copyWith(quantity: item.quantity - 1);
    state = AsyncData(updated);
  }

  void clear() {
    state = const AsyncData([]);
  }
}
