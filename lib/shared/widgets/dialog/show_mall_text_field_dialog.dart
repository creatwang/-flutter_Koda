import 'package:flutter/material.dart';
import 'package:groe_app_pad/shared/widgets/dialog/mall_dialog_anim.dart';
import 'package:groe_app_pad/shared/widgets/dialog/mall_dialog_surface.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 单行输入弹窗（如 Space）。取消返回 `null`；确定返回去首尾空格后的文本。
Future<String?> showMallTextFieldDialog({
  required BuildContext context,
  required String title,
  required String hintText,
  String? subtitle,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Add',
  bool barrierDismissible = false,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0xB30A0E14),
    builder: (BuildContext dialogContext) {
      return _MallTextFieldDialogBody(
        title: title,
        subtitle: subtitle,
        hintText: hintText,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
      );
    },
  );
}

class _MallTextFieldDialogBody extends StatefulWidget {
  const _MallTextFieldDialogBody({
    required this.title,
    required this.hintText,
    required this.cancelLabel,
    required this.confirmLabel,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String hintText;
  final String cancelLabel;
  final String confirmLabel;

  @override
  State<_MallTextFieldDialogBody> createState() =>
      _MallTextFieldDialogBodyState();
}

class _MallTextFieldDialogBodyState extends State<_MallTextFieldDialogBody> {
  late final TextEditingController _controller;
  late final FocusNode _fieldFocusNode;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _fieldFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fieldFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    if (_errorText.isEmpty) return;
    setState(() => _errorText = '');
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  void _onConfirm() {
    final v = _controller.text.trim();
    if (v.isEmpty) {
      setState(() => _errorText = widget.hintText);
      return;
    }
    Navigator.of(context).pop<String>(v);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: MallDialogEntrance(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: MallDialogSurface(
            padding: const EdgeInsets.fromLTRB(26, 22, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: ProMaxTokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.35,
                    height: 1.2,
                  ),
                ),
                if (widget.subtitle != null &&
                    widget.subtitle!.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(
                        alpha: 0.85,
                      ),
                      fontSize: 12,
                      height: 1.35,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  focusNode: _fieldFocusNode,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onConfirm(),
                  style: const TextStyle(
                    color: ProMaxTokens.textPrimary,
                    fontSize: 15,
                  ),
                  cursorColor: const Color(0xFFF4C77A),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    errorText: _errorText.isEmpty ? null : _errorText,
                    hintStyle: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(
                        alpha: 0.45,
                      ),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.28),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(14),
                        bottomLeft: Radius.circular(10),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(14),
                        bottomLeft: Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(14),
                        bottomLeft: Radius.circular(10),
                      ),
                      borderSide: const BorderSide(
                        color: Color(0xCCF4C77A),
                        width: 1.2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _onChanged,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: _onCancel,
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
                          widget.cancelLabel,
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
                        onPressed: _onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xE8F4C77A),
                          foregroundColor: const Color(0xFF1A1410),
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
                          widget.confirmLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.25,
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
  }
}
