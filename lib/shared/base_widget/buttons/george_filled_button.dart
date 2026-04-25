import 'package:flutter/material.dart';

/// 项目内通用实心 CTA（Buy now、加购、侧滑确认等），样式可通过参数覆盖。
///
/// 各构造参数含义见类内对应 `final` 字段上的文档。
///
/// 默认最小高度 40；默认圆角 8。
///
/// 需要限制高度时，优先使用 `Size(0, h)` 作为 [minimumSize]，避免
/// [Size.fromHeight]（其最小宽度为 `double.infinity`）出现在 [Row] 等
/// 水平无界约束中。
class GeorgeFilledButton extends StatelessWidget {
  const GeorgeFilledButton({
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
    this.loadingIndicatorSize = 14,
    this.loadingStrokeWidth = 2,
    this.loadingIndicatorColor,
    this.loadingGap = 8,
    this.alignment,
  });

  /// 按钮主体内容（通常为 [Text]）。
  final Widget child;

  /// 点击回调；[isLoading] 为 true 时内部会置为 null。
  final VoidCallback? onPressed;

  /// 是否处于加载态（禁用点击并展示 loading UI）。
  final bool isLoading;

  /// 启用态背景色。
  final Color backgroundColor;

  /// 启用态前景色（图标、文字、默认转圈颜色）。
  final Color foregroundColor;

  /// 禁用态背景色；为 null 时由主题决定。
  final Color? disabledBackgroundColor;

  /// 禁用态前景色；为 null 时由主题决定。
  final Color? disabledForegroundColor;

  /// 最小尺寸（默认高度 40，宽度 0 表示随内容）。
  final Size? minimumSize;

  /// 最大尺寸；为 null 时由主题决定。
  final Size? maximumSize;

  /// 固定尺寸；为 null 时不强制。
  final Size? fixedSize;

  /// 非 null 时用 [SizedBox] 包一层限定宽度（可为 `double.infinity`）。
  final double? width;

  /// 内边距；为 null 时由主题决定。
  final EdgeInsetsGeometry? padding;

  /// 阴影高度；为 null 时由主题决定。
  final double? elevation;

  /// 圆角半径；在 [shape] 与 [useThemeShape] 均未覆盖时生效（默认 8）。
  final double borderRadius;

  /// 完整形状；非 null 时优先于 [borderRadius] 的圆角矩形。
  final OutlinedBorder? shape;

  /// 为 true 时不设置 [shape]，沿用主题的按钮形状。
  final bool useThemeShape;

  /// 描边；常用于带白边的深色实心按钮。
  final BorderSide? side;

  /// [child] 左侧的图标；为 null 则不展示。
  final IconData? startIcon;

  /// [child] 右侧的图标；为 null 则不展示。
  final IconData? endIcon;

  /// [startIcon] / [endIcon] 的绘制尺寸。
  final double iconSize;

  /// 图标与 [child] 之间的水平间距。
  final double iconGap;

  /// 加载时是否仍显示 [endIcon]（默认加载时隐藏尾部图标）。
  final bool keepEndIconDuringLoading;

  /// 转圈边长（宽高一致）。
  final double loadingIndicatorSize;

  /// 转圈描边宽度。
  final double loadingStrokeWidth;

  /// 转圈颜色；为 null 时用 [foregroundColor]。
  final Color? loadingIndicatorColor;

  /// 加载转圈与主体内容之间的水平间距。
  final double loadingGap;

  /// 子内容在按钮内的对齐；为 null 时由主题决定。
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
