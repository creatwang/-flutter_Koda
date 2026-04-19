import 'package:flutter/material.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

class ProMaxInputFieldWidget extends StatelessWidget {
  const ProMaxInputFieldWidget({
    required this.label,
    required this.controller,
    super.key,
    this.obscureText = false,
    this.errorText,
    this.onTap,
    this.focusNode,
    this.labelColor,
    this.leadingIconColor,
    this.fillColor,
    this.focusedBorderColor,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? errorText;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final Color? labelColor;
  final Color? leadingIconColor;
  final Color? fillColor;
  final Color? focusedBorderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              obscureText ? Icons.lock_outline : Icons.person_outline,
              size: 14,
              color: leadingIconColor ?? ProMaxTokens.iconPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    labelColor ??
                    ProMaxTokens.textPrimary.withValues(alpha: 0.92),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          onTap: onTap,
          style: const TextStyle(color: ProMaxTokens.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: fillColor ?? ProMaxTokens.inputBackground,
            hintText: obscureText ? '********' : '',
            hintStyle: TextStyle(
              color: ProMaxTokens.textPrimary.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ProMaxTokens.radiusInput),
              borderSide: const BorderSide(color: ProMaxTokens.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ProMaxTokens.radiusInput),
              borderSide: BorderSide(
                color: focusedBorderColor ?? ProMaxTokens.inputBorderFocused,
                width: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 18,
          child: errorText == null
              ? null
              : DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0x26FF6E76),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0x55FF7F86)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 11,
                          color: Color(0xFFFFA9AD),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: SelectableText.rich(
                            TextSpan(
                              text: errorText!,
                              style: const TextStyle(
                                color: Color(0xFFFFC8CB),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
