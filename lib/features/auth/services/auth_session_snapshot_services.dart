// 将已鉴权的 [UserInfoBase] 落盘为当前会话（与登录/切店一致）。

import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/auth/services/site_info_services.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

/// 写入用户信息、当前 [companyId]、[tokenMap] 并同步站点缓存。
///
/// 当 [user] 缺少 `company_id` 或有效 `token` 时抛出 [StateError]。
Future<void> persistAuthenticatedUserSnapshot(UserInfoBase user) async {
  final companyId = user.companyId?.toInt();
  final token = user.token?.toString();
  if (companyId == null) {
    throw StateError(appL10n.errorMissingCompanyId);
  }
  if (token == null || token.isEmpty) {
    throw StateError(appL10n.errorMissingToken);
  }
  await secureStorageService.saveUserInfoBase(user);
  await secureStorageService.saveCompanyId(companyId);
  await secureStorageService.saveTokenMap(companyId, token);
  await syncSiteInfoToLocal(companyId: companyId);
}
