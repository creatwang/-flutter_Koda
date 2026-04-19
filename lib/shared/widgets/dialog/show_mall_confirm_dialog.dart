import 'package:flutter/material.dart';
import 'package:groe_app_pad/shared/widgets/dialog/mall_dialog_anim.dart';
import 'package:groe_app_pad/shared/widgets/dialog/mall_dialog_surface.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 统一确认弹窗。按钮文案为英文；标题与正文由调用方传入（可为英文）。
Future<bool?> showMallConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  IconData icon = Icons.help_outline_rounded,
  Color accentColor = const Color(0xFFFF8B6A),
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0xB30A0E14),
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: MallDialogEntrance(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: MallDialogSurface(
              child: Column(
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
                      color: ProMaxTokens.textSecondary.withValues(
                        alpha: 0.95,
                      ),
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
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
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
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: accentColor.withValues(
                              alpha: 0.92,
                            ),
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
                          child: Text(
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
              ),
            ),
          ),
        ),
      );
    },
  );
}
