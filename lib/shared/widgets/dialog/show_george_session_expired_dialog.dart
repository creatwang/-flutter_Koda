import 'package:flutter/material.dart';
import 'package:george_pick_mate/shared/widgets/dialog/george_dialog_anim.dart';
import 'package:george_pick_mate/shared/widgets/dialog/george_dialog_surface.dart';
import 'package:george_pick_mate/theme/pro_max_tokens.dart';

/// 登录失效等阻塞提示，单主按钮（英文）。
Future<void> showGeorgeSessionExpiredDialog({
  required BuildContext context,
  String title = 'Session ended',
  String message = 'Please sign in again to continue shopping.',
  String actionLabel = 'Sign in again',
  bool useRootNavigator = false,
  required Future<void> Function() onAction,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: false,
    barrierColor: const Color(0xB30A0E14),
    builder: (BuildContext dialogContext) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 28,
          ),
          child: GeorgeDialogAnim(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: GeorgeDialogSurface(
                showWarmGlow: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: ProMaxTokens.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        color: ProMaxTokens.textSecondary.withValues(
                          alpha: 0.95,
                        ),
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await onAction();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF141820),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(18),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        child: Text(
                          actionLabel,
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
              ),
            ),
          ),
        ),
      );
    },
  );
}
