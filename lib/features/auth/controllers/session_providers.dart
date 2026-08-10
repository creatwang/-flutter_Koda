import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/core/storage/token_pair.dart';
import 'package:george_pick_mate/features/auth/models/session.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/auth/controllers/main_user_providers.dart';
import 'package:george_pick_mate/features/auth/services/auth_register_services.dart';
import 'package:george_pick_mate/features/auth/services/auth_services.dart';
import 'package:george_pick_mate/features/auth/services/auth_session_snapshot_services.dart';
import 'package:george_pick_mate/features/auth/services/site_info_services.dart';
import 'package:george_pick_mate/features/cart/services/cart_persistence_services.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/features/profile/controllers/profile_providers.dart';
import 'package:george_pick_mate/features/profile/services/customer_account_services.dart';
import 'package:george_pick_mate/features/profile/services/profile_services.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

import 'login_remember_providers.dart';
import 'site_info_providers.dart';
import 'store_company_providers.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, Session>(SessionController.new);

final canExportQuotationProvider = FutureProvider<bool>((ref) async {
  return readExportQuotationCapabilityFromLocal();
});

final sessionSyncProvider = AsyncNotifierProvider<SessionSyncController, void>(
  SessionSyncController.new,
);

class SessionController extends AsyncNotifier<Session> {
  @override
  FutureOr<Session> build() async {
    await storeHostController.restoreFromStorage();
    final session = await _toSession();
    if (session.isAuthenticated) {
      await _syncRuntimeStoreHost(session.storeHost);
    }
    return session;
  }

  Future<String?> signIn({
    required String username,
    required String password,
    bool shouldRememberPassword = false,
  }) async {
    final result = await ref.read(authLoginServiceProvider)(
      username: username,
      password: password,
    );

    if (result is ApiSuccess<TokenPair>) {
      final pair = result.data;
      await ref.read(persistRememberedLoginFormProvider)(
        username: username,
        password: password,
        shouldRememberPassword: shouldRememberPassword,
      );
      state = AsyncData(
        Session(
          isAuthenticated: true,
          token: pair.token,
          storeHost: pair.storeHost,
        ),
      );
      await _syncRuntimeStoreHost(pair.storeHost);
      _invalidateAfterStoreContextChanged();
      return null;
    }

    final failure = result as ApiFailure<TokenPair>;
    return failure.exception.message;
  }

  Future<bool> register({
    required String username,
    required String password,
    required String passwordConfirm,
    bool shouldRememberPassword = false,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authRegisterServiceProvider)(
      username: username,
      password: password,
      passwordConfirm: passwordConfirm,
    );
    if (result is ApiSuccess<TokenPair>) {
      final pair = result.data;
      await ref.read(persistRememberedLoginFormProvider)(
        username: username,
        password: password,
        shouldRememberPassword: shouldRememberPassword,
      );
      state = AsyncData(
        Session(
          isAuthenticated: true,
          token: pair.token,
          storeHost: pair.storeHost,
        ),
      );
      await _syncRuntimeStoreHost(pair.storeHost);
      _invalidateAfterStoreContextChanged();
      return true;
    }
    final failure = result as ApiFailure<TokenPair>;
    state = AsyncError(failure.exception, StackTrace.current);
    return false;
  }

  /// 切换站点：更新请求域名并刷新依赖站点的本地/远端缓存。
  Future<ApiResult<void>> switchSite({required String domain}) async {
    final normalized = normalizeStoreHost(domain);
    if (normalized.isEmpty) {
      return ApiFailure<void>(AppException(appL10n.errorInvalidSiteDomain));
    }
    try {
      await storeHostController.applyDomain(normalized);
      await secureStorageService.mergeAndSaveUserInfoBase(
        UserInfoBase(domain: normalized),
        fallbackDomain: normalized,
        fallbackToken: state.asData?.value.token,
      );
      clearAllNetworkMemoryCaches();
      try {
        await clearCartListFromLocal();
        await clearSiteInfoFromLocal();
      } catch (_) {}
      await syncSiteInfoToLocal();
      state = AsyncData(
        Session(
          isAuthenticated: true,
          storeHost: normalized,
          token: state.asData?.value.token ??
              (await secureStorageService.readUserInfoBase())?.token,
        ),
      );
      _invalidateAfterStoreContextChanged();
      return const ApiSuccess<void>(null);
    } catch (e) {
      return ApiFailure<void>(AppException(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _clearLocalSessionAfterLogout();
  }

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
      } catch (_) {}
    }
    clearAllNetworkMemoryCaches();
    await ref.read(authClearTokenServiceProvider)();
    state = const AsyncData(Session(isAuthenticated: false));
    ref.invalidate(mainUserInfoProvider);
    ref.read(profileUserInfoProvider.notifier).resetAfterLogout();
  }

  Future<ApiResult<void>> loginAsStoreCustomer({
    required int customerRowId,
  }) async {
    final snapshot = await secureStorageService.readUserInfoBase();
    if (snapshot == null) {
      return ApiFailure<void>(AppException(appL10n.errorUserInfoMissing));
    }
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
    final token = next.token?.toString();
    if (token == null || token.isEmpty) {
      if (wroteMainThisCall) {
        await secureStorageService.clearMainUserInfo();
      }
      return ApiFailure<void>(AppException(appL10n.errorInvalidCustomerSession));
    }
    clearAllNetworkMemoryCaches();
    state = AsyncData(
      Session(
        isAuthenticated: true,
        storeHost: storeHostController.host,
        token: token,
      ),
    );
    _invalidateAfterStoreContextChanged();
    ref.invalidate(mainUserInfoProvider);
    return const ApiSuccess<void>(null);
  }

  Future<ApiResult<void>> switchBackToMainUser() async {
    final main = await secureStorageService.readMainUserInfo();
    if (main == null) {
      return ApiFailure<void>(AppException(appL10n.errorNoMainAccountToSwitch));
    }
    try {
      await persistAuthenticatedUserSnapshot(main);
    } catch (e) {
      return ApiFailure<void>(AppException(e.toString()));
    }
    final token = main.token?.toString();
    if (token == null || token.isEmpty) {
      return ApiFailure<void>(
        AppException(appL10n.errorInvalidMainAccountSnapshot),
      );
    }
    await secureStorageService.clearMainUserInfo();
    clearAllNetworkMemoryCaches();
    state = AsyncData(
      Session(
        isAuthenticated: true,
        storeHost: storeHostController.host,
        token: token,
      ),
    );
    _invalidateAfterStoreContextChanged();
    ref.invalidate(mainUserInfoProvider);
    return const ApiSuccess<void>(null);
  }

  void _invalidateAfterStoreContextChanged() {
    ref.invalidate(canExportQuotationProvider);
    ref.invalidate(siteCurrencySymbolProvider);
    ref.invalidate(showProductPriceProvider);
    ref.invalidate(profileUserInfoProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(favoriteProductsProvider);
    ref.invalidate(categoryTreeProvider);
    ref.invalidate(storeCompanyListProvider);
  }

  FutureOr<Session> _toSession() async {
    final user = await secureStorageService.readUserInfoBase();
    final token = user?.token?.trim();
    final storeHost = normalizeStoreHost(
      storeHostController.host ?? user?.domain ?? '',
    );
    if (token == null || token.isEmpty || storeHost.isEmpty) {
      return const Session(isAuthenticated: false);
    }
    return Session(
      isAuthenticated: true,
      storeHost: storeHost,
      token: token,
    );
  }

  /// 保证内存中的 [StoreHostController] 与当前会话站点一致（影响 baseUrl）。
  Future<void> _syncRuntimeStoreHost(String? storeHost) async {
    final normalized = normalizeStoreHost(storeHost ?? '');
    if (normalized.isEmpty) return;
    final current = storeHostController.host;
    if (current != null && normalizeStoreHost(current) == normalized) {
      return;
    }
    await storeHostController.applyDomain(normalized, persist: false);
  }
}

class SessionSyncController extends AsyncNotifier<void> {
  static const Duration _throttleWindow = Duration(seconds: 60);

  DateTime? _lastSyncedAt;
  Future<void>? _inFlightSync;

  @override
  FutureOr<void> build() {}

  Future<void> refreshOnResume() async {
    final session = ref.read(sessionControllerProvider).asData?.value;
    if (session?.isAuthenticated != true) return;

    final now = DateTime.now();
    if (_lastSyncedAt != null &&
        now.difference(_lastSyncedAt!) < _throttleWindow) {
      return;
    }
    if (_inFlightSync != null) {
      await _inFlightSync;
      return;
    }

    _inFlightSync = _runResumeSync(fallbackToken: session?.token);
    try {
      await _inFlightSync;
    } finally {
      _inFlightSync = null;
    }
  }

  Future<void> _runResumeSync({String? fallbackToken}) async {
    await Future.wait<void>([
      _refreshUserInfoCache(fallbackToken: fallbackToken),
      syncSiteInfoToLocal(),
    ]);
    _lastSyncedAt = DateTime.now();
    ref.invalidate(canExportQuotationProvider);
    ref.invalidate(siteCurrencySymbolProvider);
    ref.invalidate(showProductPriceProvider);
    ref.invalidate(profileUserInfoProvider);
  }

  Future<void> _refreshUserInfoCache({String? fallbackToken}) async {
    final result = await fetchUserInfoService();
    if (result is ApiSuccess<UserInfoBase>) {
      await secureStorageService.mergeAndSaveUserInfoBase(
        result.data,
        fallbackToken: fallbackToken,
        fallbackDomain: storeHostController.host,
      );
    }
  }
}
