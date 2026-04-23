// 「我的客户」行内查看指定 user_id 的订单分页（GET customerOrderList）。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/profile/controllers/profile_order_providers.dart';
import 'package:george_pick_mate/features/profile/services/profile_services.dart';

/// 非空时 [myCustomerUserOrdersProvider] 按该 `user_id` 请求订单列表。
final myCustomerOrdersViewUserIdProvider = NotifierProvider.autoDispose<
    MyCustomerOrdersViewUserIdNotifier,
    int?>(MyCustomerOrdersViewUserIdNotifier.new);

class MyCustomerOrdersViewUserIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setViewUserId(int? userId) => state = userId;
}

/// 与 Order Center Customer 同源接口，多传 `user_id`。
final myCustomerUserOrdersProvider = AsyncNotifierProvider.autoDispose<
    MyCustomerUserOrdersNotifier,
    ProfileOrderListState>(MyCustomerUserOrdersNotifier.new);

class MyCustomerUserOrdersNotifier
    extends AsyncNotifier<ProfileOrderListState> {
  static const int _pageSize = 20;

  ProfileOrderListState _empty() => const ProfileOrderListState(
    items: [],
    page: 1,
    hasMore: false,
    isLoadingMore: false,
    total: 0,
  );

  @override
  FutureOr<ProfileOrderListState> build() async {
    final userId = ref.watch(myCustomerOrdersViewUserIdProvider);
    if (userId == null) {
      return _empty();
    }
    final result = await fetchProfileCustomerOrderListForUserService(
      userId: userId,
      page: 1,
      pageSize: _pageSize,
    );
    return result.when(
      success: (data) => ProfileOrderListState(
        items: data.items,
        page: 1,
        hasMore: data.items.length < data.total,
        isLoadingMore: false,
        total: data.total,
      ),
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    final userId = ref.read(myCustomerOrdersViewUserIdProvider);
    if (userId == null) {
      state = AsyncData(_empty());
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchProfileCustomerOrderListForUserService(
        userId: userId,
        page: 1,
        pageSize: _pageSize,
      );
      return result.when(
        success: (data) => ProfileOrderListState(
          items: data.items,
          page: 1,
          hasMore: data.items.length < data.total,
          isLoadingMore: false,
          total: data.total,
        ),
        failure: (exception) => throw exception,
      );
    });
  }

  Future<void> loadMore() async {
    final userId = ref.read(myCustomerOrdersViewUserIdProvider);
    if (userId == null) return;
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await fetchProfileCustomerOrderListForUserService(
      userId: userId,
      page: nextPage,
      pageSize: _pageSize,
    );
    state = result.when(
      success: (data) {
        final oldIds = current.items.map((e) => e.id).toSet();
        final delta = data.items.where((e) => !oldIds.contains(e.id)).toList();
        final merged = [...current.items, ...delta];
        return AsyncData(
          current.copyWith(
            items: merged,
            page: nextPage,
            hasMore: merged.length < data.total && delta.isNotEmpty,
            isLoadingMore: false,
            total: data.total,
          ),
        );
      },
      failure: (exception) => AsyncError(exception, StackTrace.current),
    );
  }
}
