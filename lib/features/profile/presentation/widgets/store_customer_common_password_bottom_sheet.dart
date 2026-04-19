import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/profile/controllers/customer_account_providers.dart';
import 'package:groe_app_pad/shared/widgets/dismiss_keyboard_on_tap_widget.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_input_field_widget.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 底部表单：设置客户公共密码（仅密码字段）。
///
/// 外壳与 `showStoreCustomerFormBottomSheet` 一致。
Future<void> showStoreCustomerCommonPasswordBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  const String title = 'Set Command Password';
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      final double keyboardBottom = MediaQuery.viewInsetsOf(
        sheetContext,
      ).bottom;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardBottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.42,
          minChildSize: 0.28,
          maxChildSize: 0.75,
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: ProMaxTokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _CommonPasswordSheetBody(
                      scrollController: scrollController,
                      parentRef: ref,
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

class _CommonPasswordSheetBody extends StatefulWidget {
  const _CommonPasswordSheetBody({
    required this.scrollController,
    required this.parentRef,
  });

  final ScrollController scrollController;
  final WidgetRef parentRef;

  @override
  State<_CommonPasswordSheetBody> createState() =>
      _CommonPasswordSheetBodyState();
}

class _CommonPasswordSheetBodyState extends State<_CommonPasswordSheetBody> {
  late final TextEditingController _passwordController;
  late final FocusNode _passwordFocus;
  final GlobalKey _blockKey = GlobalKey();

  bool _showValidation = false;
  String? _errorMessage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _passwordFocus = FocusNode();
    _passwordFocus.addListener(_onPasswordFocus);
  }

  @override
  void dispose() {
    _passwordFocus.removeListener(_onPasswordFocus);
    _passwordFocus.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordFocus() {
    if (_passwordFocus.hasFocus) {
      _scheduleScrollIntoView();
    }
  }

  void _scheduleScrollIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 120), () async {
        if (!mounted) return;
        final BuildContext? target = _blockKey.currentContext;
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
    if (_passwordController.text.trim().length < 6) {
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
    final ApiResult<void> result = await widget.parentRef
        .read(storeCustomersProvider.notifier)
        .resetCommonPassword(password: _passwordController.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Updated successfully.')));
        Navigator.of(context).pop();
      },
      failure: (exception) {
        setState(() => _errorMessage = exception.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    return DismissKeyboardOnTap(
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            KeyedSubtree(
              key: _blockKey,
              child: ProMaxInputFieldWidget(
                label: 'PASSWORD',
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: true,
                errorText:
                    _showValidation &&
                        _passwordController.text.trim().length < 6
                    ? 'Min 6 characters'
                    : null,
              ),
            ),
            Text(
              'Applies as the shared customer account password for this store.',
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
