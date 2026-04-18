import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/models/session.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';
import 'package:groe_app_pad/features/auth/services/auth_services.dart';
import 'package:groe_app_pad/features/auth/services/site_info_services.dart';
import 'package:groe_app_pad/features/cart/services/cart_persistence_services.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_providers.dart';
import 'package:groe_app_pad/features/profile/services/profile_services.dart';

import '../../../core/platform_services/network_clients.dart';

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
    final companyId = await ref.watch(authReadTokenServiceProvider)();
    return _toSession(companyId);
  }

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
        ref.invalidate(canExportQuotationProvider);
        return true;
      },
      failure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return false;
      },
    );
  }

  Future<void> signOut() async {
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
    ref.invalidate(canExportQuotationProvider);
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

class SessionSyncController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

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
