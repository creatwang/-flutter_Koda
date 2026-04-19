// 主账号快照（代客登录前缓存），用于 Settings 中是否展示 Switch Account。

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';

/// 安全存储中的主账号 [UserInfoBase]；无代客缓存时为 `null`。
final mainUserInfoProvider = FutureProvider<UserInfoBase?>((ref) async {
  return secureStorageService.readMainUserInfo();
});
