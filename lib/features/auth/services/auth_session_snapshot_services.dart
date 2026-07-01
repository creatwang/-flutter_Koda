// 将已鉴权的 [UserInfoBase] 落盘为当前会话（与登录/切站一致）。

import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/auth/services/site_info_services.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

Future<void> persistAuthenticatedUserSnapshot(UserInfoBase user) async {
  final token = user.token?.toString();
  if (token == null || token.isEmpty) {
    throw StateError(appL10n.errorMissingToken);
  }

  var domain = user.domain?.trim();
  if (domain == null || domain.isEmpty) {
    domain = await secureStorageService.getStoreDomain();
  }
  if (domain == null || domain.isEmpty) {
    throw StateError(appL10n.errorMissingStoreDomain);
  }

  final normalized = normalizeStoreHost(domain);
  await secureStorageService.mergeAndSaveUserInfoBase(
    UserInfoBase(
      id: user.id,
      accountId: user.accountId,
      name: user.name,
      username: user.username,
      companyId: user.companyId,
      domain: normalized,
      avatar: user.avatar,
      telephone: user.telephone,
      description: user.description,
      status: user.status,
      type: user.type,
      updatedAt: user.updatedAt,
      createdAt: user.createdAt,
      deletedAt: user.deletedAt,
      registerFrom: user.registerFrom,
      languageId: user.languageId,
      tourist: user.tourist,
      email: user.email,
      nickname: user.nickname,
      wechat: user.wechat,
      customerId: user.customerId,
      lastOrderTime: user.lastOrderTime,
      userMainId: user.userMainId,
      shopId: user.shopId,
      token: token,
      isAuthAccount: user.isAuthAccount,
    ),
    fallbackDomain: normalized,
    fallbackToken: token,
  );
  await storeHostController.applyDomain(normalized);
  await syncSiteInfoToLocal();
}
