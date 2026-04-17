import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';
import 'package:groe_app_pad/features/profile/models/user_profile_info_dto.dart';
import 'package:groe_app_pad/features/profile/services/profile_services.dart';

final profileUserInfoProvider =
    AsyncNotifierProvider<ProfileUserInfoNotifier, UserProfileInfoDto>(
      ProfileUserInfoNotifier.new,
    );

class ProfileUserInfoNotifier extends AsyncNotifier<UserProfileInfoDto> {
  @override
  FutureOr<UserProfileInfoDto> build() async {
    final cached = await _readCachedProfile();
    final result = await fetchUserInfoService();
    if (result is ApiSuccess<UserProfileInfoDto>) {
      await _cacheProfile(result.data);
      return result.data;
    }
    if (cached != null) return cached;
    throw (result as ApiFailure<UserProfileInfoDto>).exception;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchUserInfoService();
      if (result is ApiSuccess<UserProfileInfoDto>) {
        await _cacheProfile(result.data);
        return result.data;
      }
      throw (result as ApiFailure<UserProfileInfoDto>).exception;
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

  Future<UserProfileInfoDto?> _readCachedProfile() async {
    final cachedMap = await secureStorageService.readUserProfileInfo();
    if (cachedMap == null) return null;
    try {
      return UserProfileInfoDto.fromJson(cachedMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheProfile(UserProfileInfoDto profile) async {
    await secureStorageService.saveUserProfileInfo(profile.toJson());
  }
}
