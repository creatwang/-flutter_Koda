import 'package:flutter/material.dart';

/// 项目内通用描边 CTA（购物车 Clear 等），样式可通过参数覆盖。
///
/// - [isLoading]：在「可选前后图标 + [child]」**右侧**追加转圈（与
///   [MallFilledCtaButtonWidget] 一致）；文案与 [startIcon] 保留。
/// - 前后图标：[startIcon] / [endIcon]，或在 [child] 内自行组合。
/// - [loadingReplacement]：非空且 [isLoading] 时，child **仅**为该组件；
///   用于需要完全复刻历史 loading 布局（如左侧转圈 + 文案）。
/// - [loadingText]：若提供，则 loading 时优先展示「转圈 + 文案」。
///
/// 默认 [minimumSize] 为 `Size(0, 40)`（勿用 [Size.fromHeight]：其宽度为
/// `double.infinity`，在 [Row] 等水平无界约束下会触发布局断言）。
/// 默认圆角 [borderRadius] 为 8；需要其他圆角时显式传 [borderRadius] 或
/// [shape]。
class MallOutlinedCtaButtonWidget extends StatelessWidget {
  const MallOutlinedCtaButtonWidget({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.foregroundColor = Colors.white,
    this.disabledForegroundColor,
    this.backgroundColor,
    this.minimumSize = const Size(0, 40),
    this.maximumSize,
    this.fixedSize,
    this.width,
    this.padding,
    this.side,
    this.shape,
    this.borderRadius = 8,
    this.startIcon,
    this.endIcon,
    this.iconSize = 16,
    this.iconGap = 6,
    this.keepEndIconDuringLoading = false,
    this.loadingIndicatorSize = 14,
    this.loadingStrokeWidth = 2,
    this.loadingIndicatorColor,
    this.loadingGap = 8,
    this.loadingText,
    this.loadingTextStyle,
    this.loadingReplacement,
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
  final IconData? startIcon;
  final IconData? endIcon;
  final double iconSize;
  final double iconGap;
  final bool keepEndIconDuringLoading;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final Color? loadingIndicatorColor;
  final double loadingGap;
  final String? loadingText;
  final TextStyle? loadingTextStyle;
  final Widget? loadingReplacement;
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
      child: _buildChild(),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }

  Widget _buildChild() {
    if (isLoading && loadingText != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: loadingIndicatorSize,
            height: loadingIndicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: loadingStrokeWidth,
              color: loadingIndicatorColor ?? foregroundColor,
            ),
          ),
          SizedBox(width: loadingGap),
          Text(
            loadingText!,
            style:
                loadingTextStyle ??
                TextStyle(color: loadingIndicatorColor ?? foregroundColor),
          ),
        ],
      );
    }
    if (isLoading && loadingReplacement != null) {
      return loadingReplacement!;
    }
    final showEndIcon =
        endIcon != null && (!isLoading || keepEndIconDuringLoading);
    final core = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (startIcon != null) ...[
          Icon(startIcon, size: iconSize, color: foregroundColor),
          SizedBox(width: iconGap),
        ],
        child,
        if (showEndIcon) ...[
          SizedBox(width: iconGap),
          Icon(endIcon!, size: iconSize, color: foregroundColor),
        ],
      ],
    );
    if (!isLoading) return core;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        core,
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
