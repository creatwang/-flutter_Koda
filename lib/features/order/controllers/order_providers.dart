import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/order/models/order_summary.dart';
import 'package:groe_app_pad/features/order/services/order_services.dart';

final ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<OrderSummary>>(
      OrdersNotifier.new,
    );

class OrdersNotifier extends AsyncNotifier<List<OrderSummary>> {
  @override
  FutureOr<List<OrderSummary>> build() async {
    return const <OrderSummary>[];
  }

  Future<void> refresh() async {
    final current = state.asData?.value ?? const <OrderSummary>[];
    state = AsyncData(current);
  }

  Future<bool> createOrderBySites({
    required List<int> companyIds,
    required List<Map<String, dynamic>> cart,
  }) async {
    final result = await createOrderBySitesService(
      companyIds: companyIds,
      cart: cart,
    );
    return result.when(success: (_) => true, failure: (_) => false);
  }
}
