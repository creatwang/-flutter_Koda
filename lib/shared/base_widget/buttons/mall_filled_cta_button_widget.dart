import 'package:flutter/material.dart';

/// 项目内通用实心 CTA（Buy now、加购、侧滑确认等），样式可通过参数覆盖。
///
/// 需要限制高度时，优先使用 `Size(0, h)` 作为 [minimumSize]，避免
/// [Size.fromHeight]（其最小宽度为 `double.infinity`）出现在 [Row] 等
/// 水平无界约束中。
class MallFilledCtaButtonWidget extends StatelessWidget {
  const MallFilledCtaButtonWidget({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = Colors.black,
    this.foregroundColor = Colors.white,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.minimumSize,
    this.maximumSize,
    this.fixedSize,
    this.width,
    this.padding,
    this.elevation,
    this.borderRadius = 5,
    this.shape,
    this.side,
    this.loadingIndicatorSize = 14,
    this.loadingStrokeWidth = 2,
    this.loadingIndicatorColor,
    this.loadingGap = 8,
    this.alignment,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Size? minimumSize;
  final Size? maximumSize;
  final Size? fixedSize;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final double borderRadius;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final Color? loadingIndicatorColor;
  final double loadingGap;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final resolvedShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        );

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: disabledBackgroundColor,
        disabledForegroundColor: disabledForegroundColor,
        minimumSize: minimumSize,
        maximumSize: maximumSize,
        fixedSize: fixedSize,
        padding: padding,
        elevation: elevation,
        shape: resolvedShape,
        side: side,
        alignment: alignment,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }

  Widget _buildChild() {
    if (!isLoading) return child;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(width: loadingGap),
        SizedBox(
          width: loadingIndicatorSize,
          height: loadingIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: loadingStrokeWidth,
            color: loadingIndicatorColor ?? foregroundColor,
          ),
        ),
      ],
    );
  }
}
