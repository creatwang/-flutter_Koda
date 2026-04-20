// 订单中心：我的订单与客户订单分页状态。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/profile/models/product_order_list_dto.dart';
import 'package:groe_app_pad/features/profile/services/profile_services.dart';

/// 订单列表一屏数据与分页元信息。
class ProfileOrderListState {
  const ProfileOrderListState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.total,
  });

  final List<OrderItemDto> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final int total;

  ProfileOrderListState copyWith({
    List<OrderItemDto>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    int? total,
  }) {
    return ProfileOrderListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      total: total ?? this.total,
    );
  }
}

/// 当前用户「我的订单」分页。
final profileMyOrderListProvider = AsyncNotifierProvider.autoDispose<
  ProfileMyOrderListNotifier,
  ProfileOrderListState
>(ProfileMyOrderListNotifier.new);

/// 业务员视角「客户订单」分页。
final profileCustomerOrderListProvider = AsyncNotifierProvider.autoDispose<
  ProfileCustomerOrderListNotifier,
  ProfileOrderListState
>(ProfileCustomerOrderListNotifier.new);

/// [fetchProfileOrderListService] 驱动的列表与加载更多。
class ProfileMyOrderListNotifier
    extends AsyncNotifier<ProfileOrderListState> {
  static const int _pageSize = 20;

  @override
  FutureOr<ProfileOrderListState> build() async {
    final result = await fetchProfileOrderListService(
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
    if (!ref.mounted) return;
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      final result = await fetchProfileOrderListService(
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
    if (!ref.mounted) return;
    state = next;
  }

  Future<void> loadMore() async {
    if (!ref.mounted) return;
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await fetchProfileOrderListService(
      page: nextPage,
      pageSize: _pageSize,
    );
    if (!ref.mounted) return;
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

/// [fetchProfileCustomerOrderListService] 驱动的列表与加载更多。
class ProfileCustomerOrderListNotifier
    extends AsyncNotifier<ProfileOrderListState> {
  static const int _pageSize = 20;

  @override
  FutureOr<ProfileOrderListState> build() async {
    final result = await fetchProfileCustomerOrderListService(
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
    if (!ref.mounted) return;
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      final result = await fetchProfileCustomerOrderListService(
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
    if (!ref.mounted) return;
    state = next;
  }

  Future<void> loadMore() async {
    if (!ref.mounted) return;
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await fetchProfileCustomerOrderListService(
      page: nextPage,
      pageSize: _pageSize,
    );
    if (!ref.mounted) return;
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
