import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/auth/services/site_info_services.dart';
import 'package:groe_app_pad/l10n/app_localizations.dart';
import 'package:groe_app_pad/features/product/services/product_sku_cart_helpers.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

/// 站点 `product_addcart_space == 1` 时收集用户输入的 `space`。
/// 取消返回 `null`，确定返回非空字符串。
Future<String?> showCartSpaceInputDialog(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _CartSpaceInputDialog(l10n: l10n),
  );
}

class _CartSpaceInputDialog extends StatefulWidget {
  const _CartSpaceInputDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_CartSpaceInputDialog> createState() => _CartSpaceInputDialogState();
}

class _CartSpaceInputDialogState extends State<_CartSpaceInputDialog> {
  late final TextEditingController _controller;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
      setState(() => _errorText = widget.l10n.cartSpaceDialogHint);
      return;
    }
    Navigator.of(context).pop<String>(v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardBottom),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AlertDialog(
        insetPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        title: Text(l10n.cartSpaceDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onConfirm(),
                decoration: InputDecoration(
                  hintText: l10n.cartSpaceDialogHint,
                  errorText: _errorText.isEmpty ? null : _errorText,
                ),
                onChanged: _onChanged,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: _onCancel, child: Text(l10n.commonCancel)),
          FilledButton(onPressed: _onConfirm, child: Text(l10n.commonConfirm)),
        ],
      ),
    );
  }
}

/// 站点要求时弹窗输入 `space`；否则返回 [kCartSpaceDefault]。
/// 用户取消（仅在选择性弹窗场景）返回 `null`。
Future<String?> resolveSpaceForCartAdd(BuildContext context) async {
  final site = await readSiteInfoFromLocal();
  if (!context.mounted) return null;
  if (site?.productAddcartSpace == 1) {
    return showCartSpaceInputDialog(context);
  }
  return kCartSpaceDefault;
}
