import 'package:flutter/material.dart';

/// 弹窗入场：轻微缩放，不显式叠一层从 0 开始的 [Opacity]。
///
/// 外层 [DialogRoute] 已带 [FadeTransition]；若此处再用缩放值推导
/// [Opacity]，在 ticker 未推进时会出现「只有遮罩、面板全透明」。
class GeorgeDialogAnim extends StatelessWidget {
  const GeorgeDialogAnim({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 240),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TickerMode(
      enabled: true,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0.98, end: 1),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.scale(
            scale: value,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
