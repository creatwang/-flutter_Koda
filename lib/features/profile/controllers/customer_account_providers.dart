// 业务员「我的客户」列表分页。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/auth/models/session.dart';
import 'package:groe_app_pad/features/profile/models/paginated_store_customers_state.dart';
import 'package:groe_app_pad/features/profile/models/store_customer_item_dto.dart';
import 'package:groe_app_pad/features/profile/services/customer_account_services.dart';

/// 客户列表（下拉刷新、滚动加载；依赖当前会话 `companyId` + `token`）。
final storeCustomersProvider =
    AsyncNotifierProvider<StoreCustomersNotifier, PaginatedStoreCustomersState>(
      StoreCustomersNotifier.new,
    );

class StoreCustomersNotifier
    extends AsyncNotifier<PaginatedStoreCustomersState> {
  static const int _pageSize = 20;

  String _status = '';
  String _keyword = '';

  @override
  FutureOr<PaginatedStoreCustomersState> build() async {
    // 同时依赖 companyId 与 token，避免仅 token 变化时仍沿用旧列表。
    final session = ref.watch(
      sessionControllerProvider.select(
        (AsyncValue<Session> async) => async.asData?.value,
      ),
    );
    final companyId = session?.companyId;
    final String? token = session?.token;
    if (companyId == null || token == null || token.isEmpty) {
      return const PaginatedStoreCustomersState(
        items: [],
        page: 1,
        hasMore: false,
      );
    }
    final result = await fetchStoreCustomersFirstPageService(
      companyId: companyId,
      status: _status,
      keyword: _keyword,
      pageSize: _pageSize,
    );
    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  /// 更新筛选并回到第一页。
  Future<void> applyFilters({String? status, String? keyword}) async {
    _status = status ?? _status;
    _keyword = keyword ?? _keyword;
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final companyId = ref
          .read(sessionControllerProvider)
          .asData
          ?.value
          .companyId;
      if (companyId == null) {
        return const PaginatedStoreCustomersState(
          items: [],
          page: 1,
          hasMore: false,
        );
      }
      final result = await fetchStoreCustomersFirstPageService(
        companyId: companyId,
        status: _status,
        keyword: _keyword,
        pageSize: _pageSize,
      );
      return result.when(
        success: (data) => data,
        failure: (exception) => throw exception,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    final companyId = ref
        .read(sessionControllerProvider)
        .asData
        ?.value
        .companyId;
    if (current == null ||
        companyId == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await fetchStoreCustomersPageService(
      companyId: companyId,
      page: nextPage,
      status: _status,
      keyword: _keyword,
      pageSize: _pageSize,
    );

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

  /// `POST /store/account/customerResetPwd`，与列表状态无耦合。
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
