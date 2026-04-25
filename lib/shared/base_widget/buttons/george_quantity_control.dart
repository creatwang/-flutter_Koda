import 'dart:async';

import 'package:flutter/material.dart';

/// 数量加减按钮尺寸档位。
enum QuantityControl {
  /// 小号：适合紧凑布局。
  small,

  /// 中号：默认档位（与原购物车尺寸一致）。
  middle,

  /// 大号：适合强调交互的场景。
  large,
}

/// 购物车/预订单通用数量加减图标按钮。
///
/// 支持点击与长按连发触发。
class GeorgeQuantityControl extends StatelessWidget {
  const GeorgeQuantityControl({
    super.key,
    required this.quantityText,
    required this.isDecreaseEnabled,
    required this.isIncreaseEnabled,
    required this.onDecreaseTap,
    required this.onIncreaseTap,
    this.onDecreaseLongPressStart,
    this.onDecreaseLongPressEnd,
    this.onIncreaseLongPressStart,
    this.onIncreaseLongPressEnd,
    this.size = QuantityControl.middle,
  });

  /// 中间数量文案（例如：`3 box`）。
  final String quantityText;

  /// 减号按钮是否可点击。
  final bool isDecreaseEnabled;

  /// 加号按钮是否可点击。
  final bool isIncreaseEnabled;

  /// 点击减号回调。
  final Future<void> Function() onDecreaseTap;

  /// 点击加号回调。
  final Future<void> Function() onIncreaseTap;

  /// 减号按钮长按开始回调（用于启动连续减）。
  final VoidCallback? onDecreaseLongPressStart;

  /// 减号按钮长按结束/取消回调（用于停止连续减）。
  final VoidCallback? onDecreaseLongPressEnd;

  /// 加号按钮长按开始回调（用于启动连续加）。
  final VoidCallback? onIncreaseLongPressStart;

  /// 加号按钮长按结束/取消回调（用于停止连续加）。
  final VoidCallback? onIncreaseLongPressEnd;

  /// 尺寸档位（默认 [QuantityControl.middle]）。
  final QuantityControl size;

  @override
  Widget build(BuildContext context) {
    final token = _controlTokensOf(size);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(token.containerRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      padding: token.containerPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityActionButton(
            icon: Icons.remove,
            enabled: isDecreaseEnabled,
            side: token.buttonSide,
            iconSize: token.iconSize,
            radius: token.buttonRadius,
            onTap: onDecreaseTap,
            onLongPressStart: onDecreaseLongPressStart,
            onLongPressEnd: onDecreaseLongPressEnd,
          ),
          SizedBox(width: token.horizontalGap),
          Text(
            quantityText,
            style: TextStyle(
              color: Colors.white,
              fontSize: token.textSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: token.horizontalGap),
          _QuantityActionButton(
            icon: Icons.add,
            enabled: isIncreaseEnabled,
            side: token.buttonSide,
            iconSize: token.iconSize,
            radius: token.buttonRadius,
            onTap: onIncreaseTap,
            onLongPressStart: onIncreaseLongPressStart,
            onLongPressEnd: onIncreaseLongPressEnd,
          ),
        ],
      ),
    );
  }
}

class _QuantityActionButton extends StatelessWidget {
  const _QuantityActionButton({
    required this.icon,
    required this.enabled,
    required this.side,
    required this.iconSize,
    required this.radius,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final IconData icon;
  final bool enabled;
  final double side;
  final double iconSize;
  final double radius;
  final Future<void> Function() onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => unawaited(onTap()) : null,
      onLongPressStart: enabled && onLongPressStart != null
          ? (_) => onLongPressStart!()
          : null,
      onLongPressEnd: enabled && onLongPressEnd != null
          ? (_) => onLongPressEnd!()
          : null,
      onLongPressCancel: enabled && onLongPressEnd != null
          ? onLongPressEnd
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: side,
        height: side,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: enabled ? Colors.white : Colors.white30,
        ),
      ),
    );
  }
}

_QuantityControlTokens _controlTokensOf(QuantityControl size) {
  return switch (size) {
    QuantityControl.small => const _QuantityControlTokens(
      buttonSide: 14,
      iconSize: 10,
      buttonRadius: 4,
      containerRadius: 7,
      containerPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      textSize: 10,
      horizontalGap: 6,
    ),
    QuantityControl.middle => const _QuantityControlTokens(
      buttonSide: 22,
      iconSize: 14,
      buttonRadius: 6,
      containerRadius: 9,
      containerPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      textSize: 12,
      horizontalGap: 10,
    ),
    QuantityControl.large => const _QuantityControlTokens(
      buttonSide: 28,
      iconSize: 18,
      buttonRadius: 8,
      containerRadius: 10,
      containerPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      textSize: 13,
      horizontalGap: 10,
    ),
  };
}

class _QuantityControlTokens {
  const _QuantityControlTokens({
    required this.buttonSide,
    required this.iconSize,
    required this.buttonRadius,
    required this.containerRadius,
    required this.containerPadding,
    required this.textSize,
    required this.horizontalGap,
  });

  final double buttonSide;
  final double iconSize;
  final double buttonRadius;
  final double containerRadius;
  final EdgeInsets containerPadding;
  final double textSize;
  final double horizontalGap;
}
