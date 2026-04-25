import 'package:flutter/material.dart';

/// 圆角方框复选框：外框尺寸由 [boxSide] 固定，对勾仅通过 [checkIconSize] 缩小，
/// 与 Material [Checkbox] 不同，对勾不会随方框同比放大。
class GeorgeCheckboxButton extends StatelessWidget {
  const GeorgeCheckboxButton({
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

  /// 是否勾选。
  final bool value;

  /// 状态变更回调；为 null 时禁用交互。
  final ValueChanged<bool>? onChanged;

  /// 方框边长。
  final double boxSide;

  /// 对勾图标尺寸。
  final double checkIconSize;

  /// 方框圆角半径。
  final double borderRadius;

  /// 未选中时边框颜色。
  final Color borderColor;

  /// 边框线宽。
  final double borderWidth;

  /// 选中时方框填充色。
  final Color checkedFillColor;

  /// 对勾颜色。
  final Color checkColor;

  /// 可点热区边长（扩大触摸范围）。
  final double touchExtent;

  /// 无障碍标签。
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
