import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/order/models/order_create_item.dart';
import 'package:groe_app_pad/features/order/models/order_summary.dart';
import 'package:groe_app_pad/features/order/services/order_services.dart';

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderSummary>>(
  OrdersNotifier.new,
);

class OrdersNotifier extends AsyncNotifier<List<OrderSummary>> {
  @override
  FutureOr<List<OrderSummary>> build() async {
    final result = await fetchOrdersService(limit: 10);
    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchOrdersService(limit: 10);
      return result.when(
        success: (data) => data,
        failure: (exception) => throw exception,
      );
    });
  }

  Future<bool> createOrder({
    required int userId,
    required List<OrderCreateItem> items,
  }) async {
    final result = await createOrderService(
      userId: userId,
      items: items,
    );
    return result.when(
      success: (order) {
        final current = state.asData?.value ?? [];
        state = AsyncData([order, ...current]);
        return true;
      },
      failure: (_) => false,
    );
  }
}
