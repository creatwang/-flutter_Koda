// 个人中心：用户信息缓存与更新。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';
import 'package:groe_app_pad/features/profile/services/profile_services.dart';

/// 当前用户资料（优先读本地缓存，再拉远端）。
final profileUserInfoProvider =
    AsyncNotifierProvider<ProfileUserInfoNotifier, UserInfoBase>(
      ProfileUserInfoNotifier.new,
    );

/// 同步 [UserInfoBase] 与安全存储，并提供资料更新入口。
class ProfileUserInfoNotifier extends AsyncNotifier<UserInfoBase> {
  @override
  FutureOr<UserInfoBase> build() async {
    final cached = await _readCachedProfile();
    if (cached != null) return cached;

    final result = await fetchUserInfoService();
    if (result is ApiSuccess<UserInfoBase>) {
      await _cacheProfile(result.data);
      return result.data;
    }
    throw (result as ApiFailure<UserInfoBase>).exception;
  }

  /// 登出后由会话层调用：清空内存态（登出路径不 invalidate 本 provider）。
  void resetAfterLogout() {
    state = AsyncData(UserInfoBase());
  }

  /// 强制从接口拉取并覆盖缓存。
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchUserInfoService();
      if (result is ApiSuccess<UserInfoBase>) {
        await _cacheProfile(result.data);
        return result.data;
      }
      throw (result as ApiFailure<UserInfoBase>).exception;
    });
  }

  /// 更新姓名与可选密码；成功后会 [refresh]。
  ///
  /// [name] / 密码字段：与 [updateUserInfoService] 一致。
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

  Future<void> _cacheProfile(UserInfoBase profile) async {
    await secureStorageService.saveUserInfoBase(profile);
  }
}
