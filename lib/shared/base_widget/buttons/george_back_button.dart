import 'package:flutter/material.dart';

/// [GeorgeBackButton] 上图标相对文案的位置。
enum GeorgeBackButtonIconPosition {
  /// 图标在文案左侧（默认）。
  leading,

  /// 图标在文案右侧。
  trailing,
}

/// 详情等页顶「返回列表」实心按钮，图标与配色可通过参数覆盖。
///
/// [iconPosition] 控制 [icon] 在 [label] 前或后；不包含 loading 态；
/// 提交中禁用返回请在外层对 [onPressed] 置 null。
///
/// 各构造参数含义见类内对应 `final` 字段上的文档。
class GeorgeBackButton extends StatelessWidget {
  const GeorgeBackButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = Icons.arrow_back,
    this.iconSize = 16,
    this.iconPosition = GeorgeBackButtonIconPosition.leading,
    this.iconLabelGap = 8,
    this.backgroundColor = const Color.fromRGBO(129, 119, 110, 1),
    this.foregroundColor = Colors.white,
    this.textStyle,
    this.minimumSize,
    this.padding,
    this.visualDensity,
    this.elevation,
    this.borderRadius = 8,
  });

  /// 点击回调；为 null 时按钮禁用。
  final VoidCallback? onPressed;

  /// 主文案。
  final String label;

  /// 与文案同排的图标（默认返回箭头）。
  final IconData icon;

  /// 图标边长（逻辑像素）。
  final double iconSize;

  /// 图标在文案左侧或右侧。
  final GeorgeBackButtonIconPosition iconPosition;

  /// 图标与文案之间的水平间距。
  final double iconLabelGap;

  /// 按钮背景色。
  final Color backgroundColor;

  /// 前景色（图标、文字默认继承）。
  final Color foregroundColor;

  /// 文案样式；为 null 时使用前景色构建默认样式。
  final TextStyle? textStyle;

  /// 最小点击区域；为 null 时由主题决定。
  final Size? minimumSize;

  /// 内边距；为 null 时由主题决定。
  final EdgeInsetsGeometry? padding;

  /// 视觉密度；为 null 时由主题决定。
  final VisualDensity? visualDensity;

  /// 阴影高度；为 null 时由主题决定。
  final double? elevation;

  /// 圆角矩形半径（默认 8）。
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: iconSize, color: foregroundColor);
    final labelWidget = Text(
      label,
      style: textStyle ?? TextStyle(color: foregroundColor),
    );
    final gap = SizedBox(width: iconLabelGap);
    final rowChildren =
        iconPosition == GeorgeBackButtonIconPosition.leading
            ? <Widget>[iconWidget, gap, labelWidget]
            : <Widget>[labelWidget, gap, iconWidget];

    return FilledButton(
      style: FilledButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        minimumSize: minimumSize,
        padding: padding,
        visualDensity: visualDensity,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
    );
  }
}
