import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/models/session.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';
import 'package:groe_app_pad/features/auth/controllers/main_user_providers.dart';
import 'package:groe_app_pad/features/auth/services/auth_services.dart';
import 'package:groe_app_pad/features/auth/services/auth_session_snapshot_services.dart';
import 'package:groe_app_pad/features/auth/services/site_info_services.dart';
import 'package:groe_app_pad/features/auth/services/store_company_services.dart';
import 'package:groe_app_pad/features/cart/services/cart_persistence_services.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_providers.dart';
import 'package:groe_app_pad/features/profile/services/customer_account_services.dart';
import 'package:groe_app_pad/features/profile/services/profile_services.dart';

import 'store_company_providers.dart';

/// 会话：登录态、[Session] 同步、站点切换、前后台刷新编排。
final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, Session>(SessionController.new);

/// 本地站点配置是否包含导出报价插件能力。
final canExportQuotationProvider = FutureProvider<bool>((ref) async {
  return readExportQuotationCapabilityFromLocal();
});

/// 应用回到前台时的用户信息与站点信息刷新（节流在 [AppShell]）。
final sessionSyncProvider = AsyncNotifierProvider<SessionSyncController, void>(
  SessionSyncController.new,
);

/// 维护 [Session]：登录、登出、切换站点。
class SessionController extends AsyncNotifier<Session> {
  @override
  FutureOr<Session> build() async {
    final companyId = await ref.watch(authReadTokenServiceProvider)();
    return _toSession(companyId);
  }

  /// 用户名密码登录；成功则 [state] 为已认证会话。
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authLoginServiceProvider)(
      username: username,
      password: password,
    );

    return result.when(
      success: (TokenPair pair) {
        state = AsyncData(
          Session(
            isAuthenticated: true,
            token: pair.token,
            companyId: pair.companyId,
          ),
        );
        _invalidateAfterStoreContextChanged();
        return true;
      },
      failure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return false;
      },
    );
  }

  /// 切换到指定门店/站点（已登录）。
  ///
  /// [companyId]、[shopId]：与接口一致，通常均为列表项中的 `id`。
  /// 成功后会更新内存中的 [Session]、本地 `userInfoBase` / `companyId` /
  /// `tokenMap` 并 [syncSiteInfoToLocal]；同时失效依赖站点/用户的若干
  /// provider（购物车由 [sessionControllerProvider] 监听自动刷新）。
  Future<ApiResult<void>> switchShop({
    required int companyId,
    required int shopId,
  }) async {
    final result = await switchShopService(
      companyId: companyId,
      shopId: shopId,
    );
    return result.when(
      success: (UserInfoBase user) {
        final cid = user.companyId?.toInt();
        final token = user.token?.toString();
        if (cid == null || token == null || token.isEmpty) {
          return ApiFailure<void>(
            AppException('Invalid user payload after switch'),
          );
        }
        state = AsyncData(
          Session(isAuthenticated: true, companyId: cid, token: token),
        );
        _invalidateAfterStoreContextChanged();
        return const ApiSuccess<void>(null);
      },
      failure: (exception) => ApiFailure<void>(exception),
    );
  }

  /// 清除令牌与本地购物车/站点缓存，会话置为未登录（不请求服务端）。
  ///
  /// 用于 token 失效、拦截器回调等场景。
  Future<void> signOut() async {
    await _clearLocalSessionAfterLogout();
  }

  /// 先请求 `POST /store/user/logout`，成功后再清理本地会话并失效相关
  /// provider；失败则保留本地登录态并返回 [ApiFailure]。
  Future<ApiResult<void>> signOutWithRemoteLogout() async {
    final previousSession = state.asData?.value;
    if (previousSession?.isAuthenticated != true) {
      await _clearLocalSessionAfterLogout();
      return const ApiSuccess<void>(null);
    }
    final remote = await logoutStoreUserService();
    if (remote is ApiFailure<void>) {
      return remote;
    }
    await _clearLocalSessionAfterLogout();
    return const ApiSuccess<void>(null);
  }

  Future<void> _clearLocalSessionAfterLogout() async {
    final previousSession = state.asData?.value;
    if (previousSession?.isAuthenticated == true) {
      try {
        await clearCartListFromLocal();
        await clearSiteInfoFromLocal();
      } catch (_) {
        // SharedPreferences 在部分测试环境未初始化，允许安全降级。
      }
    }
    await ref.read(authClearTokenServiceProvider)();
    state = const AsyncData(Session(isAuthenticated: false));
    // 登出：不调其它业务接口；仅清本地 + 同步内存态。
    // 勿 invalidate 商品/订单等（会触发 build 拉网）。
    ref.invalidate(mainUserInfoProvider);
    ref.read(profileUserInfoProvider.notifier).resetAfterLogout();
  }

  /// 业务员代客登录：先缓存主账号，再写入客户会话并刷新依赖数据。
  Future<ApiResult<void>> loginAsStoreCustomer({
    required int customerRowId,
  }) async {
    final snapshot = await secureStorageService.readUserInfoBase();
    if (snapshot == null) {
      return ApiFailure<void>(AppException('User info missing'));
    }
    // 仅业务员上下文写入主账号快照；已在代客态时勿用当前客户信息覆盖
    // `main_user_info`。
    final existingMain = await secureStorageService.readMainUserInfo();
    final wroteMainThisCall = existingMain == null;
    if (wroteMainThisCall) {
      await secureStorageService.saveMainUserInfo(snapshot);
    }

    final loginResult = await loginStoreCustomerService(id: customerRowId);
    if (loginResult is ApiFailure<UserInfoBase>) {
      if (wroteMainThisCall) {
        await secureStorageService.clearMainUserInfo();
      }
      return ApiFailure<void>(loginResult.exception);
    }
    final next = (loginResult as ApiSuccess<UserInfoBase>).data;
    try {
      await persistAuthenticatedUserSnapshot(next);
    } catch (e) {
      if (wroteMainThisCall) {
        await secureStorageService.clearMainUserInfo();
      }
      return ApiFailure<void>(AppException(e.toString()));
    }
    final cid = next.companyId?.toInt();
    final token = next.token?.toString();
    if (cid == null || token == null || token.isEmpty) {
      if (wroteMainThisCall) {
        await secureStorageService.clearMainUserInfo();
      }
      return ApiFailure<void>(AppException('Invalid customer session'));
    }
    state = AsyncData(
      Session(isAuthenticated: true, companyId: cid, token: token),
    );
    _invalidateAfterStoreContextChanged();
    ref.invalidate(mainUserInfoProvider);
    return const ApiSuccess<void>(null);
  }

  /// 从代客会话切回主账号，并清除主账号缓存。
  Future<ApiResult<void>> switchBackToMainUser() async {
    final main = await secureStorageService.readMainUserInfo();
    if (main == null) {
      return ApiFailure<void>(AppException('No main account to switch'));
    }
    try {
      await persistAuthenticatedUserSnapshot(main);
    } catch (e) {
      return ApiFailure<void>(AppException(e.toString()));
    }
    final cid = main.companyId?.toInt();
    final token = main.token?.toString();
    if (cid == null || token == null || token.isEmpty) {
      return ApiFailure<void>(AppException('Invalid main account snapshot'));
    }
    await secureStorageService.clearMainUserInfo();
    state = AsyncData(
      Session(isAuthenticated: true, companyId: cid, token: token),
    );
    _invalidateAfterStoreContextChanged();
    ref.invalidate(mainUserInfoProvider);
    return const ApiSuccess<void>(null);
  }

  void _invalidateAfterStoreContextChanged() {
    ref.invalidate(canExportQuotationProvider);
    ref.invalidate(profileUserInfoProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(favoriteProductsProvider);
    ref.invalidate(categoryTreeProvider);
    ref.invalidate(storeCompanyListProvider);
    // 客户列表已在 build 内 watch 会话，勿再 invalidate（会循环 import）。
  }

  FutureOr<Session> _toSession(int? companyId) async {
    if (companyId == null) {
      return const Session(isAuthenticated: false);
    }
    final token = await secureStorageService.getTokenByCompanyId(companyId);
    if (token == null || token.isEmpty) {
      return const Session(isAuthenticated: false);
    }
    return Session(isAuthenticated: true, companyId: companyId, token: token);
  }
}

/// 前台恢复触发的轻量同步（不持有业务状态）。
class SessionSyncController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// 并行刷新用户信息缓存与站点信息（失败静默）。
  Future<void> refreshOnResume() async {
    final session = ref.read(sessionControllerProvider).asData?.value;
    if (session?.isAuthenticated != true) return;
    final companyId = session?.companyId;
    if (companyId == null) return;

    await Future.wait<void>([
      _refreshUserInfoCache(),
      syncSiteInfoToLocal(companyId: companyId),
    ]);
    ref.invalidate(canExportQuotationProvider);
    ref.invalidate(profileUserInfoProvider);
  }

  Future<void> _refreshUserInfoCache() async {
    final result = await fetchUserInfoService();
    if (result is ApiSuccess<UserInfoBase>) {
      await secureStorageService.saveUserInfoBase(result.data);
    }
  }
}
