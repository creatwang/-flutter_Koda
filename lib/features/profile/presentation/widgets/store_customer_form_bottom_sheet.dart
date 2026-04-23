import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/features/profile/controllers/customer_account_providers.dart';
import 'package:george_pick_mate/features/profile/models/store_customer_item_dto.dart';
import 'package:george_pick_mate/shared/widgets/dismiss_keyboard_on_tap_widget.dart';
import 'package:george_pick_mate/shared/widgets/pro_max_input_field_widget.dart';
import 'package:george_pick_mate/theme/pro_max_tokens.dart';

enum StoreCustomerSheetMode { create, edit }

/// 底部表单：新增或编辑客户账号（Username 必填；Password 必填且不少于 6 位）。
///
/// 外壳样式与切换站点底部弹层一致：透明底、可拖拽高度、`#1A1D24` 面板、
/// 顶边线、拖动手柄与标题区。
Future<void> showStoreCustomerFormBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required StoreCustomerSheetMode mode,
  StoreCustomerItemDto? editing,
}) {
  final title = mode == StoreCustomerSheetMode.create
      ? 'New Customer'
      : 'Edit Customer';
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      final keyboardBottom = MediaQuery.viewInsetsOf(sheetContext).bottom;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardBottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.58,
          minChildSize: 0.36,
          maxChildSize: 0.92,
          builder: (BuildContext context, ScrollController scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFF1A1D24),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(top: BorderSide(color: Color(0x44FFFFFF))),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: ProMaxTokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _StoreCustomerFormSheetBody(
                      scrollController: scrollController,
                      parentRef: ref,
                      mode: mode,
                      editing: editing,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _StoreCustomerFormSheetBody extends StatefulWidget {
  const _StoreCustomerFormSheetBody({
    required this.scrollController,
    required this.parentRef,
    required this.mode,
    this.editing,
  });

  final ScrollController scrollController;
  final WidgetRef parentRef;
  final StoreCustomerSheetMode mode;
  final StoreCustomerItemDto? editing;

  @override
  State<_StoreCustomerFormSheetBody> createState() =>
      _StoreCustomerFormSheetBodyState();
}

class _StoreCustomerFormSheetBodyState
    extends State<_StoreCustomerFormSheetBody> {
  static const int _kFieldBlockCount = 4;

  final List<GlobalKey> _fieldBlockKeys = List<GlobalKey>.generate(
    _kFieldBlockCount,
    (_) => GlobalKey(),
  );

  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final List<FocusNode> _fieldFocusNodes;

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
    _fieldFocusNodes = List<FocusNode>.generate(_kFieldBlockCount, (int i) {
      final GlobalKey blockKey = _fieldBlockKeys[i];
      final FocusNode node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          _scheduleScrollBlockIntoView(blockKey);
        }
      });
      return node;
    });
  }

  @override
  void dispose() {
    for (final FocusNode n in _fieldFocusNodes) {
      n.dispose();
    }
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _scheduleScrollBlockIntoView(GlobalKey blockKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 120), () async {
        if (!mounted) return;
        final BuildContext? target = blockKey.currentContext;
        if (target == null || !target.mounted) return;
        await Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.12,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      });
    });
  }

  bool _validate() {
    final u = _usernameController.text.trim();
    final p = _passwordController.text.trim();
    if (u.isEmpty) {
      _errorMessage = 'Username or Email is required.';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Success')));
        Navigator.of(context).pop();
      },
      failure: (exception) {
        setState(() => _errorMessage = exception.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DismissKeyboardOnTap(
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            KeyedSubtree(
              key: _fieldBlockKeys[0],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ProMaxInputFieldWidget(
                    label: 'USERNAME OR EMAIL',
                    controller: _usernameController,
                    focusNode: _fieldFocusNodes[0],
                    obscureText: false,
                    errorText:
                        _showValidation &&
                            _usernameController.text.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  Text(
                    'Login identifier for this customer account.',
                    style: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            KeyedSubtree(
              key: _fieldBlockKeys[1],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ProMaxInputFieldWidget(
                    label: 'PASSWORD',
                    controller: _passwordController,
                    focusNode: _fieldFocusNodes[1],
                    obscureText: true,
                    errorText:
                        _showValidation &&
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
                ],
              ),
            ),
            const SizedBox(height: 12),
            KeyedSubtree(
              key: _fieldBlockKeys[2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ProMaxInputFieldWidget(
                    label: 'NAME',
                    controller: _nameController,
                    focusNode: _fieldFocusNodes[2],
                    obscureText: false,
                  ),
                  Text(
                    'Display name.',
                    style: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            KeyedSubtree(
              key: _fieldBlockKeys[3],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ProMaxInputFieldWidget(
                    label: 'PHONE',
                    controller: _phoneController,
                    focusNode: _fieldFocusNodes[3],
                    obscureText: false,
                  ),
                  Text(
                    'Contact telephone.',
                    style: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFF4C77A),
                      ),
                    )
                  : const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
