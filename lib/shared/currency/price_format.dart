/// 将金额文本与站点货币符号拼接；[symbol] 为空时只返回金额。
String formatPriceText({
  required String amountText,
  required String symbol,
}) {
  if (symbol.isEmpty) return amountText;
  return '$symbol$amountText';
}

/// 格式化数值金额并拼接货币符号。
String formatPrice({
  required num amount,
  required String symbol,
  int? fractionDigits,
}) {
  final amountText = fractionDigits == null
      ? amount.toString()
      : amount.toStringAsFixed(fractionDigits);
  return formatPriceText(amountText: amountText, symbol: symbol);
}
