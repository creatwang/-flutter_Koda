import 'package:flutter/material.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

class ProfileSettingsAccountActionButtonWidget extends StatelessWidget {
  const ProfileSettingsAccountActionButtonWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;
  final bool isDanger;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading;
    final iconColor = isDanger
        ? const Color(0xFFFF9EA1)
        : ProMaxTokens.iconPrimary;
    final titleColor = isDanger
        ? const Color(0xFFFFD7D8)
        : ProMaxTokens.textPrimary;
    return Opacity(
      opacity: (!isEnabled && !isLoading) ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canTap
              ? () async {
                  await onTap();
                }
              : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDanger
                    ? const [Color(0x38FF6E76), Color(0x1B2A1216)]
                    : const [Color(0x2D8ED0FF), Color(0x150D1A2C)],
              ),
              border: Border.all(
                color: isDanger
                    ? const Color(0x66FF6E76)
                    : ProMaxTokens.inputBorderFocused.withValues(
                        alpha: 0.70,
                      ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 18),
                    if (isLoading) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ProMaxTokens.textSecondary.withValues(
                      alpha: 0.92,
                    ),
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
