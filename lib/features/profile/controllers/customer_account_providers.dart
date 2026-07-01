// 业务员「我的客户」列表分页。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/auth/models/session.dart';
import 'package:george_pick_mate/features/profile/models/paginated_store_customers_state.dart';
import 'package:george_pick_mate/features/profile/models/store_customer_item_dto.dart';
import 'package:george_pick_mate/features/profile/services/customer_account_services.dart';

final storeCustomersProvider =
    AsyncNotifierProvider.autoDispose<
      StoreCustomersNotifier,
      PaginatedStoreCustomersState
    >(
      StoreCustomersNotifier.new,
    );

class StoreCustomersNotifier
    extends AsyncNotifier<PaginatedStoreCustomersState> {
  static const int _pageSize = 20;

  static const PaginatedStoreCustomersState _emptyFirstPage =
      PaginatedStoreCustomersState(
    items: [],
    page: 1,
    hasMore: false,
  );

  String _status = '';
  String _keyword = '';

  Future<bool> _isSalesRepContext() async {
    final user = await secureStorageService.readUserInfoBase();
    return user?.isAuthAccount == true;
  }

  @override
  FutureOr<PaginatedStoreCustomersState> build() async {
    final session = ref.watch(
      sessionControllerProvider.select(
        (AsyncValue<Session> async) => async.asData?.value,
      ),
    );
    final String? token = session?.token;
    if (session?.isAuthenticated != true ||
        token == null ||
        token.isEmpty) {
      return _emptyFirstPage;
    }
    if (!await _isSalesRepContext()) {
      return _emptyFirstPage;
    }
    final result = await fetchStoreCustomersFirstPageService(
      status: _status,
      keyword: _keyword,
      pageSize: _pageSize,
    );
    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  Future<void> applyFilters({String? status, String? keyword}) async {
    _status = status ?? _status;
    _keyword = keyword ?? _keyword;
    await refresh();
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      final session = ref.read(sessionControllerProvider).asData?.value;
      if (session?.isAuthenticated != true) {
        return _emptyFirstPage;
      }
      if (!await _isSalesRepContext()) {
        return _emptyFirstPage;
      }
      final result = await fetchStoreCustomersFirstPageService(
        status: _status,
        keyword: _keyword,
        pageSize: _pageSize,
      );
      return result.when(
        success: (data) => data,
        failure: (exception) => throw exception,
      );
    });
    if (!ref.mounted) return;
    state = next;
  }

  Future<void> loadMore() async {
    if (!ref.mounted) return;
    final current = state.asData?.value;
    final session = ref.read(sessionControllerProvider).asData?.value;
    if (current == null ||
        session?.isAuthenticated != true ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    if (!await _isSalesRepContext()) {
      return;
    }

    if (!ref.mounted) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await fetchStoreCustomersPageService(
      page: nextPage,
      status: _status,
      keyword: _keyword,
      pageSize: _pageSize,
    );

    if (!ref.mounted) return;
    state = result.when(
      success: (pageData) {
        final oldIds = current.items.map((e) => e.id).toSet();
        final delta = pageData.items
            .where((e) => !oldIds.contains(e.id))
            .toList();
        final merged = [...current.items, ...delta];
        return AsyncData(
          current.copyWith(
            items: merged,
            page: nextPage,
            hasMore: pageData.hasMore,
            isLoadingMore: false,
            totalCount: pageData.totalCount ?? current.totalCount,
          ),
        );
      },
      failure: (exception) => AsyncError(exception, StackTrace.current),
    );
  }

  Future<ApiResult<void>> createCustomer({
    required String username,
    required String password,
    required String name,
    required String telephone,
  }) async {
    final result = await createStoreCustomerService(
      username: username,
      password: password,
      name: name,
      telephone: telephone,
    );
    if (result is ApiSuccess<void>) {
      await refresh();
    }
    return result;
  }

  Future<ApiResult<void>> updateCustomer({
    required int id,
    required String username,
    required String password,
    required String name,
    required String telephone,
  }) async {
    final result = await updateStoreCustomerService(
      id: id,
      username: username,
      password: password,
      name: name,
      telephone: telephone,
    );
    if (result is ApiSuccess<void>) {
      await refresh();
    }
    return result;
  }

  Future<ApiResult<void>> resetCommonPassword({required String password}) {
    return resetStoreCustomerCommonPasswordService(password: password);
  }

  Future<ApiResult<void>> deleteCustomer(StoreCustomerItemDto item) async {
    final result = await deleteStoreCustomerService(id: item.id);
    if (result is ApiSuccess<void>) {
      await refresh();
    }
    return result;
  }
}
