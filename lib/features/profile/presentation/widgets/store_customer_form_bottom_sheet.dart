import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/profile/controllers/customer_account_providers.dart';
import 'package:groe_app_pad/features/profile/models/store_customer_item_dto.dart';
import 'package:groe_app_pad/shared/widgets/dismiss_keyboard_on_tap_widget.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_input_field_widget.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

enum StoreCustomerSheetMode { create, edit }

/// 底部表单：新增或编辑客户账号（Username / Password 必填且不少于 6 位）。
Future<void> showStoreCustomerFormBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required StoreCustomerSheetMode mode,
  StoreCustomerItemDto? editing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ProMaxTokens.panelBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: DismissKeyboardOnTap(
        child: _StoreCustomerFormSheetBody(
          parentRef: ref,
          mode: mode,
          editing: editing,
        ),
      ),
    ),
  );
}

class _StoreCustomerFormSheetBody extends StatefulWidget {
  const _StoreCustomerFormSheetBody({
    required this.parentRef,
    required this.mode,
    this.editing,
  });

  final WidgetRef parentRef;
  final StoreCustomerSheetMode mode;
  final StoreCustomerItemDto? editing;

  @override
  State<_StoreCustomerFormSheetBody> createState() =>
      _StoreCustomerFormSheetBodyState();
}

class _StoreCustomerFormSheetBodyState extends State<_StoreCustomerFormSheetBody> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _showValidation = false;
  String? _errorMessage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _usernameController = TextEditingController(text: e?.username ?? '');
    _passwordController = TextEditingController();
    _nameController = TextEditingController(text: e?.name ?? '');
    _phoneController = TextEditingController(text: e?.telephone ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    final u = _usernameController.text.trim();
    final p = _passwordController.text.trim();
    if (u.length < 6) {
      _errorMessage = 'Username or Email must be at least 6 characters.';
      return false;
    }
    if (p.length < 6) {
      _errorMessage = 'Password must be at least 6 characters.';
      return false;
    }
    _errorMessage = null;
    return true;
  }

  Future<void> _onDone() async {
    setState(() {
      _showValidation = true;
      _errorMessage = null;
    });
    if (!_validate()) {
      setState(() {});
      return;
    }
    setState(() => _submitting = true);
    final notifier = widget.parentRef.read(storeCustomersProvider.notifier);
    final ApiResult<void> result;
    if (widget.mode == StoreCustomerSheetMode.create) {
      result = await notifier.createCustomer(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        telephone: _phoneController.text.trim(),
      );
    } else {
      final id = widget.editing?.id;
      if (id == null) {
        setState(() => _submitting = false);
        return;
      }
      result = await notifier.updateCustomer(
        id: id,
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        telephone: _phoneController.text.trim(),
      );
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')),
        );
        Navigator.of(context).pop();
      },
      failure: (exception) {
        setState(() => _errorMessage = exception.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == StoreCustomerSheetMode.create
        ? 'New customer'
        : 'Edit customer';
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ProMaxTokens.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: ProMaxTokens.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProMaxInputFieldWidget(
              label: 'USERNAME OR EMAIL',
              controller: _usernameController,
              obscureText: false,
              errorText: _showValidation &&
                      _usernameController.text.trim().length < 6
                  ? 'Min 6 characters'
                  : null,
            ),
            Text(
              'Login identifier for this customer account.',
              style: TextStyle(
                color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            ProMaxInputFieldWidget(
              label: 'PASSWORD',
              controller: _passwordController,
              obscureText: true,
              errorText: _showValidation &&
                      _passwordController.text.trim().length < 6
                  ? 'Min 6 characters'
                  : null,
            ),
            Text(
              'Required for create and update (min 6 characters).',
              style: TextStyle(
                color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            ProMaxInputFieldWidget(
              label: 'NAME',
              controller: _nameController,
              obscureText: false,
            ),
            Text(
              'Display name.',
              style: TextStyle(
                color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            ProMaxInputFieldWidget(
              label: 'PHONE',
              controller: _phoneController,
              obscureText: false,
            ),
            Text(
              'Contact telephone.',
              style: TextStyle(
                color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              SelectableText.rich(
                TextSpan(
                  text: _errorMessage,
                  style: const TextStyle(
                    color: Color(0xFFFF6E76),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _onDone,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
