/// 后台 `siteInfo.currency` 约定值。
enum CurrencyCode {
  rmb('RMB'),
  usd('USD'),
  eur('EUR'),
  gbp('GBP'),
  hkd('HKD'),
  aud('AUD'),
  cad('CAD'),
  php('PHP');

  const CurrencyCode(this.code);

  final String code;

  static CurrencyCode? tryParse(String? raw) {
    final normalized = raw?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final value in CurrencyCode.values) {
      if (value.code == normalized) return value;
    }
    return null;
  }
}

/// 币种简写 → 货币符号。
const Map<CurrencyCode, String> currencySymbolMap = <CurrencyCode, String>{
  CurrencyCode.rmb: '¥',
  CurrencyCode.usd: '\$',
  CurrencyCode.eur: '€',
  CurrencyCode.gbp: '£',
  CurrencyCode.hkd: 'HK\$',
  CurrencyCode.aud: 'A\$',
  CurrencyCode.cad: 'C\$',
  CurrencyCode.php: '₱',
};

/// 未知 / 空 → 空字符串（展示时不带符号）。
String currencySymbolOf(String? code) {
  final parsed = CurrencyCode.tryParse(code);
  if (parsed == null) return '';
  return currencySymbolMap[parsed]!;
}
