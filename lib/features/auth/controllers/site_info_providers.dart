import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/auth/services/site_info_services.dart';
import 'package:george_pick_mate/shared/currency/currency_code.dart';

/// 当前站点货币符号；未知或未加载时为空字符串。
final siteCurrencySymbolProvider = FutureProvider<String>((ref) async {
  final siteInfo = await readSiteInfoFromLocal();
  return currencySymbolOf(siteInfo?.currency);
});
