import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/auth/presentation/providers/auth_providers.dart';
import 'package:groe_app_pad/features/order/data/data_sources/order_remote_data_source.dart';
import 'package:groe_app_pad/features/order/data/repositories/order_repository_impl.dart';
import 'package:groe_app_pad/features/order/domain/entities/order_create_item.dart';
import 'package:groe_app_pad/features/order/domain/entities/order_summary.dart';
import 'package:groe_app_pad/features/order/domain/repositories/order_repository.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>(
  (ref) => OrderRemoteDataSource(ref.watch(authDioClientProvider)),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepositoryImpl(ref.watch(orderRemoteDataSourceProvider)),
);

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderSummary>>(
  OrdersNotifier.new,
);

class OrdersNotifier extends AsyncNotifier<List<OrderSummary>> {
  @override
  FutureOr<List<OrderSummary>> build() async {
    final result = await ref.watch(orderRepositoryProvider).fetchOrders(limit: 10);
    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(orderRepositoryProvider).fetchOrders(limit: 10);
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
    final result = await ref.read(orderRepositoryProvider).createOrder(
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
