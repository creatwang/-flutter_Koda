import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';
import 'package:groe_app_pad/features/profile/services/profile_services.dart';

final profileUserInfoProvider =
    AsyncNotifierProvider<ProfileUserInfoNotifier, UserInfoBase>(
      ProfileUserInfoNotifier.new,
    );

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
