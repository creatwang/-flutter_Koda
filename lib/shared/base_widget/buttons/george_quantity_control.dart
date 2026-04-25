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
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.size = QuantityControl.middle,
  });

  /// 显示图标（通常为 `Icons.remove` 或 `Icons.add`）。
  final IconData icon;

  /// 是否可点击。
  final bool enabled;

  /// 单击回调。
  final Future<void> Function() onTap;

  /// 长按开始回调（用于启动连续加减）。
  final VoidCallback? onLongPressStart;

  /// 长按结束/取消回调（用于停止连续加减）。
  final VoidCallback? onLongPressEnd;

  /// 尺寸档位（默认 [QuantityControl.middle]）。
  final QuantityControl size;

  @override
  Widget build(BuildContext context) {
    final token = _tokensOf(size);
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
        width: token.side,
        height: token.side,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(token.radius),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Icon(
          icon,
          size: token.iconSize,
          color: enabled ? Colors.white : Colors.white30,
        ),
      ),
    );
  }
}

_QuantityAdjustTokens _tokensOf(QuantityControl size) {
  return switch (size) {
    QuantityControl.small => const _QuantityAdjustTokens(
      side: 18,
      iconSize: 12,
      radius: 5,
    ),
    QuantityControl.middle => const _QuantityAdjustTokens(
      side: 22,
      iconSize: 14,
      radius: 6,
    ),
    QuantityControl.large => const _QuantityAdjustTokens(
      side: 28,
      iconSize: 18,
      radius: 8,
    ),
  };
}

class _QuantityAdjustTokens {
  const _QuantityAdjustTokens({
    required this.side,
    required this.iconSize,
    required this.radius,
  });

  final double side;
  final double iconSize;
  final double radius;
}
