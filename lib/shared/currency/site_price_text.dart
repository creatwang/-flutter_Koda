import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/auth/controllers/site_info_providers.dart';
import 'package:george_pick_mate/shared/currency/price_format.dart';

/// 使用站点货币符号展示价格；符号未就绪或未知时只显示金额。
class SitePriceText extends ConsumerWidget {
  const SitePriceText({
    required this.amountText,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String amountText;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol =
        ref.watch(siteCurrencySymbolProvider).asData?.value ?? '';
    return Text(
      formatPriceText(amountText: amountText, symbol: symbol),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
