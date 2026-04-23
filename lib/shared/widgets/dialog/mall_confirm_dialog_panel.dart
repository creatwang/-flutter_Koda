import 'package:flutter/material.dart';
import 'package:george_pick_mate/theme/pro_max_tokens.dart';

/// 商城统一确认弹窗的内容区（图标、标题、正文、双按钮）。
///
/// 外层由调用方包 [MallDialogSurface] / [Dialog] 等；与购物车
/// [showMallConfirmDialog] 使用同一套视觉。
class MallConfirmDialogPanel extends StatelessWidget {
  const MallConfirmDialogPanel({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.cancelLabel,
    required this.confirmLabel,
    this.confirmChild,
    this.onCancel,
    this.onConfirm,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final String cancelLabel;
  final String confirmLabel;

  /// 非空时作为主按钮子组件（例如 loading），并忽略 [confirmLabel] 文案。
  final Widget? confirmChild;

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(14),
                  bottomLeft: Radius.circular(10),
                ),
                color: accentColor.withValues(alpha: 0.18),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: ProMaxTokens.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.35,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          message,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ProMaxTokens.textSecondary.withValues(alpha: 0.95),
            height: 1.55,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 26),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                child: Text(
                  cancelLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor.withValues(alpha: 0.92),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
                child: confirmChild ??
                    Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
