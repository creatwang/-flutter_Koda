// 个人中心：用户信息缓存与更新。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/features/profile/services/profile_services.dart';

final profileUserInfoProvider =
    AsyncNotifierProvider<ProfileUserInfoNotifier, UserInfoBase>(
      ProfileUserInfoNotifier.new,
    );

class ProfileUserInfoNotifier extends AsyncNotifier<UserInfoBase> {
  @override
  FutureOr<UserInfoBase> build() async {
    final cached = await _readCachedProfile();
    await _ensureStoreHostContext(cached);

    if (cached != null && cached.hasProfileIdentity) {
      return cached;
    }

    final storeHost = await _resolveStoreHost(cached);
    if (storeHost == null) return UserInfoBase();

    final result = await fetchUserInfoService();
    if (result is ApiSuccess<UserInfoBase>) {
      return _cacheProfile(result.data);
    }
    if (cached != null) return cached;
    throw (result as ApiFailure<UserInfoBase>).exception;
  }

  void resetAfterLogout() {
    state = AsyncData(UserInfoBase());
  }

  Future<void> refresh() async {
    final cached = await _readCachedProfile();
    await _ensureStoreHostContext(cached);
    final storeHost = await _resolveStoreHost(cached);
    if (storeHost == null) {
      state = AsyncData(UserInfoBase());
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchUserInfoService();
      if (result is ApiSuccess<UserInfoBase>) {
        return _cacheProfile(result.data);
      }
      throw (result as ApiFailure<UserInfoBase>).exception;
    });
  }

  Future<ApiResult<void>> updateUserInfo({
    required String name,
    required String oldPassword,
    required String newPassword,
    required String conPassword,
  }) async {
    final result = await updateUserInfoService(
      name: name,
      oldPassword: oldPassword,
      newPassword: newPassword,
      conPassword: conPassword,
    );
    await result.when(success: (_) => refresh(), failure: (_) async {});
    return result;
  }

  Future<UserInfoBase?> _readCachedProfile() async {
    return secureStorageService.readUserInfoBase();
  }

  Future<String?> _resolveStoreHost(UserInfoBase? cached) async {
    final stored = await secureStorageService.getStoreDomain();
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }
    final memoryHost = storeHostController.host?.trim();
    if (memoryHost != null && memoryHost.isNotEmpty) return memoryHost;
    final fromCache = cached?.domain?.trim();
    if (fromCache != null && fromCache.isNotEmpty) {
      return normalizeStoreHost(fromCache);
    }
    final user = await secureStorageService.readUserInfoBase();
    final fromUser = user?.domain?.trim();
    if (fromUser == null || fromUser.isEmpty) return null;
    return normalizeStoreHost(fromUser);
  }

  Future<void> _ensureStoreHostContext(UserInfoBase? cached) async {
    final stored = await secureStorageService.getStoreDomain();
    if (stored != null && stored.trim().isNotEmpty) {
      if (storeHostController.host == null) {
        await storeHostController.applyDomain(stored, persist: false);
      }
      return;
    }
    final resolved = await _resolveStoreHost(cached);
    if (resolved == null || resolved.isEmpty) return;
    await storeHostController.applyDomain(resolved);
  }

  Future<UserInfoBase> _cacheProfile(UserInfoBase profile) async {
    return secureStorageService.mergeAndSaveUserInfoBase(
      profile,
      fallbackDomain: storeHostController.host,
    );
  }
}
