import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/auth/services/site_info_services.dart';
import 'package:george_pick_mate/shared/currency/currency_code.dart';

/// 当前站点货币符号；未知或未加载时为空字符串。
final siteCurrencySymbolProvider = FutureProvider<String>((ref) async {
  final siteInfo = await readSiteInfoFromLocal();
  return currencySymbolOf(siteInfo?.currency);
});

/// 是否展示商品价格与货币符号；`show_product_price` 为 0 时为 false。
final showProductPriceProvider = FutureProvider<bool>((ref) async {
  final siteInfo = await readSiteInfoFromLocal();
  return siteInfo?.showProductPrice != 0;
});
