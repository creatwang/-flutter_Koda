import 'package:flutter/material.dart';

/// 详情等页顶「返回列表」实心按钮，图标与配色可通过参数覆盖。
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
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize, color: foregroundColor),
      label: Text(label, style: textStyle ?? TextStyle(color: foregroundColor)),
    );
  }
}
