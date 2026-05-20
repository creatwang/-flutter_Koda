import 'package:flutter/material.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';
import 'package:george_pick_mate/shared/widgets/dialog/george_confirm_dialog_panel.dart';
import 'package:george_pick_mate/shared/widgets/dialog/george_dialog_anim.dart';
import 'package:george_pick_mate/shared/widgets/dialog/george_dialog_surface.dart';

/// 统一确认弹窗。按钮文案默认取自 [AppLocalizations]；标题与正文由调用方传入。
///
/// [showCancelButton] 为 `false` 时仅展示 [confirmLabel] 主按钮（如导出成功提示）。
Future<bool?> showGeorgeConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? cancelLabel,
  String? confirmLabel,
  bool showCancelButton = true,
  IconData icon = Icons.help_outline_rounded,
  Color accentColor = const Color(0xFFFF8B6A),
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0xB30A0E14),
    builder: (BuildContext dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      final resolvedCancel = cancelLabel ?? l10n.commonCancel;
      final resolvedConfirm = confirmLabel ?? l10n.commonConfirm;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 28,
        ),
        child: GeorgeDialogAnim(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: GeorgeDialogSurface(
              child: GeorgeConfirmDialogPanel(
                title: title,
                message: message,
                cancelLabel: resolvedCancel,
                confirmLabel: resolvedConfirm,
                showCancelButton: showCancelButton,
                icon: icon,
                accentColor: accentColor,
                onCancel: showCancelButton
                    ? () => Navigator.of(dialogContext).pop(false)
                    : null,
                onConfirm: () => Navigator.of(dialogContext).pop(true),
              ),
            ),
          ),
        ),
      );
    },
  );
}
