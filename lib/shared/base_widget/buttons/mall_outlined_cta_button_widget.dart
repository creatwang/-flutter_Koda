import 'package:flutter/material.dart';

/// 项目内通用描边 CTA（购物车 Clear 等），样式可通过参数覆盖。
class MallOutlinedCtaButtonWidget extends StatelessWidget {
  const MallOutlinedCtaButtonWidget({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.foregroundColor = Colors.white,
    this.disabledForegroundColor,
    this.backgroundColor,
    this.minimumSize = const Size.fromHeight(44),
    this.maximumSize,
    this.fixedSize,
    this.width,
    this.padding,
    this.side,
    this.shape,
    this.borderRadius = 4,
    this.loadingIndicatorSize = 16,
    this.loadingStrokeWidth = 2,
    this.loadingIndicatorColor,
    this.alignment,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color foregroundColor;
  final Color? disabledForegroundColor;
  final Color? backgroundColor;
  final Size? minimumSize;
  final Size? maximumSize;
  final Size? fixedSize;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final double borderRadius;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final Color? loadingIndicatorColor;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final resolvedSide =
        side ?? BorderSide(color: foregroundColor.withValues(alpha: 0.38));
    final resolvedShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        );

    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        disabledForegroundColor: disabledForegroundColor,
        backgroundColor: backgroundColor,
        minimumSize: minimumSize,
        maximumSize: maximumSize,
        fixedSize: fixedSize,
        padding: padding,
        side: resolvedSide,
        shape: resolvedShape,
        alignment: alignment,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: loadingIndicatorSize,
              height: loadingIndicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: loadingStrokeWidth,
                color: loadingIndicatorColor ?? foregroundColor,
              ),
            )
          : child,
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
