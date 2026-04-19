// 将已鉴权的 [UserInfoBase] 落盘为当前会话（与登录/切店一致）。

import 'package:groe_app_pad/core/platform_services/network_clients.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';
import 'package:groe_app_pad/features/auth/services/site_info_services.dart';

/// 写入用户信息、当前 [companyId]、[tokenMap] 并同步站点缓存。
///
/// 当 [user] 缺少 `company_id` 或有效 `token` 时抛出 [StateError]。
Future<void> persistAuthenticatedUserSnapshot(UserInfoBase user) async {
  final companyId = user.companyId?.toInt();
  final token = user.token?.toString();
  if (companyId == null) {
    throw StateError('Missing company_id');
  }
  if (token == null || token.isEmpty) {
    throw StateError('Missing token');
  }
  await secureStorageService.saveUserInfoBase(user);
  await secureStorageService.saveCompanyId(companyId);
  await secureStorageService.saveTokenMap(companyId, token);
  await syncSiteInfoToLocal(companyId: companyId);
}
