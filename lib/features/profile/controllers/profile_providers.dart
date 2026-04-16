import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/profile/models/user_profile_info_dto.dart';
import 'package:groe_app_pad/features/profile/services/profile_services.dart';

final profileUserInfoProvider =
    AsyncNotifierProvider<ProfileUserInfoNotifier, UserProfileInfoDto>(
  ProfileUserInfoNotifier.new,
);

class ProfileUserInfoNotifier extends AsyncNotifier<UserProfileInfoDto> {
  @override
  FutureOr<UserProfileInfoDto> build() async {
    final result = await fetchUserInfoService();
    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchUserInfoService();
      return result.when(
        success: (data) => data,
        failure: (exception) => throw exception,
      );
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
    await result.when(
      success: (_) => refresh(),
      failure: (_) async {},
    );
    return result;
  }
}
