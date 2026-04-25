import 'package:flutter/material.dart';

/// 弹窗外壳：非对称圆角、轻渐变、细描边与柔光阴影（温暖 / 呼吸感）。
///
/// 不使用 [BackdropFilter]，避免与 [AppShell] 全局毛玻璃及侧滑路由遮罩
/// 叠加后，在部分平台（尤其 Windows）上出现内容层空白、只剩弹窗遮罩
/// 的现象。
class GeorgeDialogSurface extends StatelessWidget {
  const GeorgeDialogSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(26, 22, 22, 24),
    this.showWarmGlow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showWarmGlow;

  static const BorderRadius _radii = BorderRadius.only(
    topLeft: Radius.circular(26),
    topRight: Radius.circular(14),
    bottomRight: Radius.circular(24),
    bottomLeft: Radius.circular(18),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _radii,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: _radii,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xF01E222B),
              Color(0xF012161E),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Color(0x33FF9F73),
              blurRadius: 42,
              spreadRadius: -18,
              offset: Offset(18, -14),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (showWarmGlow)
              Positioned(
                right: -40,
                top: -50,
                child: IgnorePointer(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          Color(0x33FFC9A8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
