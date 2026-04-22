import 'package:flutter/material.dart';

/// 圆角方框复选框：外框尺寸由 [boxSide] 固定，对勾仅通过 [checkIconSize] 缩小，
/// 与 Material [Checkbox] 不同，对勾不会随方框同比放大。
class SmallCheckSquareCheckboxWidget extends StatelessWidget {
  const SmallCheckSquareCheckboxWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.boxSide = 16,
    this.checkIconSize = 11,
    this.borderRadius = 4,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.5,
    this.checkedFillColor = const Color.fromRGBO(136, 136, 136, 1),
    this.checkColor = Colors.white,
    this.touchExtent = 40,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double boxSide;
  final double checkIconSize;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color checkedFillColor;
  final Color checkColor;
  final double touchExtent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final radius = BorderRadius.circular(borderRadius);

    return Semantics(
      label: semanticLabel,
      checked: value,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? () => onChanged!(!value) : null,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: SizedBox(
              width: touchExtent,
              height: touchExtent,
              child: Center(
                child: Ink(
                  width: boxSide,
                  height: boxSide,
                  decoration: BoxDecoration(
                    color: value ? checkedFillColor : Colors.transparent,
                    borderRadius: radius,
                    border: Border.all(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
                  child: value
                      ? Center(
                          child: Icon(
                            Icons.check,
                            size: checkIconSize,
                            color: checkColor,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
