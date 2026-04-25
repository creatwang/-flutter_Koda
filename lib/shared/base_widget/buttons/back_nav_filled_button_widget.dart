import 'package:flutter/material.dart';

/// 详情等页顶「返回列表」实心按钮，图标与配色可通过参数覆盖。
///
/// 使用 Material [FilledButton.icon]：**仅前图标**（[icon]）+ 文案 [label]；
/// 不包含 loading 态；提交中禁用返回请在外层对 [onPressed] 置 null。
///
/// 默认圆角 [borderRadius] 为 8。
class BackNavFilledButtonWidget extends StatelessWidget {
  const BackNavFilledButtonWidget({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = Icons.arrow_back,
    this.iconSize = 16,
    this.backgroundColor = const Color.fromRGBO(129, 119, 110, 1),
    this.foregroundColor = Colors.white,
    this.textStyle,
    this.minimumSize,
    this.padding,
    this.visualDensity,
    this.elevation,
    this.borderRadius = 8,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final double iconSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle? textStyle;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final double? elevation;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
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
      icon: Icon(icon, size: iconSize, color: foregroundColor),
      label: Text(label, style: textStyle ?? TextStyle(color: foregroundColor)),
    );
  }
}
