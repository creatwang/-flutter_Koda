import 'package:flutter/material.dart';

/// 项目内通用实心 CTA（Buy now、加购、侧滑确认等），样式可通过参数覆盖。
///
/// - [isLoading] 为 true 时：在「图标 + [child] +（可选尾部图标）」整体**右侧**
///   追加 [CircularProgressIndicator]；[onPressed] 为 null。
/// - 文案前后图标：可用 [startIcon] / [endIcon]，或在 [child] 内自行拼
///   [Row]（复杂排版时用后者）。
/// - [keepEndIconDuringLoading]：加载时是否保留 [endIcon]（例如始终显示
///   箭头时可设为 true）。
/// - [loadingOnlyIndicator]：为 true 时，loading 态只显示转圈；常用于
///   「提交中仅图标」按钮。
/// - [loadingReplacement]：非空且 [isLoading] 时，按钮 child **仅**为该
///   组件（用于「仅转圈」等与默认「文案 + 尾转圈」不同的样式）。
///
/// 默认最小高度为 40；需要其他高度时显式传 [minimumSize]。
/// 默认圆角 [borderRadius] 为 8；需要其他圆角时显式传 [borderRadius] 或
/// [shape]。
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
    this.minimumSize = const Size(0, 40),
    this.maximumSize,
    this.fixedSize,
    this.width,
    this.padding,
    this.elevation,
    this.borderRadius = 8,
    this.shape,
    this.useThemeShape = false,
    this.side,
    this.startIcon,
    this.endIcon,
    this.iconSize = 16,
    this.iconGap = 6,
    this.keepEndIconDuringLoading = false,
    this.loadingOnlyIndicator = false,
    this.loadingIndicatorSize = 14,
    this.loadingStrokeWidth = 2,
    this.loadingIndicatorColor,
    this.loadingGap = 8,
    this.loadingReplacement,
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
  final bool useThemeShape;
  final BorderSide? side;
  final IconData? startIcon;
  final IconData? endIcon;
  final double iconSize;
  final double iconGap;
  final bool keepEndIconDuringLoading;
  final bool loadingOnlyIndicator;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final Color? loadingIndicatorColor;
  final double loadingGap;
  final Widget? loadingReplacement;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final resolvedShape = useThemeShape
        ? null
        : (shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ));

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
    if (isLoading && loadingOnlyIndicator) {
      return SizedBox(
        width: loadingIndicatorSize,
        height: loadingIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: loadingStrokeWidth,
          color: loadingIndicatorColor ?? foregroundColor,
        ),
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
