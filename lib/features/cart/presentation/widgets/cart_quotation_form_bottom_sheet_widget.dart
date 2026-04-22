import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/cart/models/cart_quotation_config_dto.dart';
import 'package:groe_app_pad/shared/widgets/dismiss_keyboard_on_tap_widget.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

Future<Map<String, dynamic>?> showCartQuotationFormBottomSheet({
  required BuildContext context,
  required List<CartQuotationFormFieldDto> fields,
  required Future<String?> Function(Map<String, dynamic> formData) onPreview,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Export Quotation',
                        style: TextStyle(
                          color: ProMaxTokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _CartQuotationFormSheetBody(
                      scrollController: scrollController,
                      fields: fields,
                      onPreview: onPreview,
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

class _CartQuotationFormSheetBody extends StatefulWidget {
  const _CartQuotationFormSheetBody({
    required this.scrollController,
    required this.fields,
    required this.onPreview,
  });

  final ScrollController scrollController;
  final List<CartQuotationFormFieldDto> fields;
  final Future<String?> Function(Map<String, dynamic> formData) onPreview;

  @override
  State<_CartQuotationFormSheetBody> createState() =>
      _CartQuotationFormSheetBodyState();
}

class _CartQuotationFormSheetBodyState
    extends State<_CartQuotationFormSheetBody> {
  final Map<String, TextEditingController> _textControllers =
      <String, TextEditingController>{};
  final Map<String, String?> _selectedLabels = <String, String?>{};
  final Map<String, String> _fieldErrors = <String, String>{};
  String? _errorMessage;
  bool _submitting = false;
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      if (field.type == CartQuotationFormFieldType.select) {
        _selectedLabels[field.field] = _resolveInitialSelectLabel(field);
      } else {
        _textControllers[field.field] = TextEditingController(
          text: _toInitialText(field.defaultValue),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _toInitialText(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text;
  }

  String? _resolveInitialSelectLabel(CartQuotationFormFieldDto field) {
    if (field.options.isEmpty) return null;
    final rawDefault = _toInitialText(field.defaultValue);
    if (rawDefault.isNotEmpty) {
      if (field.options.containsKey(rawDefault)) return rawDefault;
      for (final entry in field.options.entries) {
        if (entry.value == rawDefault) return entry.key;
      }
    }
    return field.options.keys.first;
  }

  void _adjustNumberField(CartQuotationFormFieldDto field, int delta) {
    final controller = _textControllers[field.field];
    if (controller == null) return;
    final current = num.tryParse(controller.text.trim()) ?? 0;
    final next = current + delta;
    final safe = next < 0 ? 0 : next;
    final hasDecimal = safe is double && safe != safe.roundToDouble();
    controller.text = hasDecimal ? safe.toString() : safe.toInt().toString();
    setState(() => _fieldErrors.remove(field.field));
  }

  bool _validate() {
    _fieldErrors.clear();
    for (final field in widget.fields) {
      if (!field.isRequired) continue;
      if (field.type == CartQuotationFormFieldType.select) {
        final selected = _selectedLabels[field.field];
        if (selected == null || selected.trim().isEmpty) {
          _fieldErrors[field.field] = 'Required';
        }
        continue;
      }
      final value = _textControllers[field.field]?.text.trim() ?? '';
      if (value.isEmpty) {
        _fieldErrors[field.field] = 'Required';
      }
    }
    return _fieldErrors.isEmpty;
  }

  Map<String, dynamic> _buildResultMap() {
    final result = <String, dynamic>{};
    for (final field in widget.fields) {
      if (field.type == CartQuotationFormFieldType.select) {
        final label = _selectedLabels[field.field];
        final selectedValue = label == null ? '' : field.options[label] ?? '';
        result[field.field] = selectedValue;
        continue;
      }
      final rawText = _textControllers[field.field]?.text.trim() ?? '';
      if (field.type == CartQuotationFormFieldType.number) {
        result[field.field] = num.tryParse(rawText) ?? rawText;
      } else {
        result[field.field] = rawText;
      }
    }
    return result;
  }

  Future<void> _onDone() async {
    setState(() {
      _errorMessage = null;
    });
    if (!_validate()) {
      setState(() {});
      return;
    }
    setState(() => _submitting = true);
    final result = _buildResultMap();
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop(result);
  }

  Future<void> _onPreview() async {
    setState(() => _errorMessage = null);
    if (!_validate()) {
      setState(() {});
      return;
    }
    final result = _buildResultMap();
    setState(() => _previewing = true);
    final errorMessage = await widget.onPreview(result);
    if (!mounted) return;
    setState(() {
      _previewing = false;
      _errorMessage = errorMessage;
    });
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
          children: <Widget>[
            ...widget.fields.map(_buildFieldBlock),
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previewing || _submitting ? null : _onPreview,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Color(0x55FFFFFF)),
                    ),
                    child: _previewing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting || _previewing ? null : _onDone,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldBlock(CartQuotationFormFieldDto field) {
    final errorText = _fieldErrors[field.field];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              Text(
                field.title.toUpperCase(),
                style: const TextStyle(
                  color: ProMaxTokens.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              if (field.isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Color(0xFFFF6E76),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (field.type == CartQuotationFormFieldType.text)
            _buildTextField(field)
          else if (field.type == CartQuotationFormFieldType.number)
            _buildNumberField(field)
          else
            _buildSelectField(field),
          const SizedBox(height: 6),
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText.rich(
                          TextSpan(
                            text: errorText,
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
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(CartQuotationFormFieldDto field) {
    final controller = _textControllers[field.field]!;
    return TextField(
      controller: controller,
      style: const TextStyle(color: ProMaxTokens.textPrimary),
      onChanged: (_) => setState(() => _fieldErrors.remove(field.field)),
      decoration: InputDecoration(
        isDense: true,
        constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: ProMaxTokens.inputBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProMaxTokens.radiusInput),
          borderSide: const BorderSide(color: ProMaxTokens.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProMaxTokens.radiusInput),
          borderSide: const BorderSide(
            color: ProMaxTokens.inputBorderFocused,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(CartQuotationFormFieldDto field) {
    final controller = _textControllers[field.field]!;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: ProMaxTokens.inputBackground,
        borderRadius: BorderRadius.circular(ProMaxTokens.radiusInput),
        border: Border.all(color: ProMaxTokens.inputBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          _NumberActionButton(
            icon: Icons.remove,
            onPressed: () => _adjustNumberField(field, -1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: ProMaxTokens.textPrimary),
              onChanged: (_) =>
                  setState(() => _fieldErrors.remove(field.field)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _NumberActionButton(
            icon: Icons.add,
            onPressed: () => _adjustNumberField(field, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectField(CartQuotationFormFieldDto field) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLabels[field.field],
      isExpanded: true,
      dropdownColor: const Color(0xFF1A1D24),
      iconEnabledColor: ProMaxTokens.textSecondary,
      style: const TextStyle(color: ProMaxTokens.textPrimary),
      items: field.options.keys
          .map(
            (label) =>
                DropdownMenuItem<String>(value: label, child: Text(label)),
          )
          .toList(growable: false),
      onChanged: (value) {
        setState(() {
          _selectedLabels[field.field] = value;
          _fieldErrors.remove(field.field);
        });
      },
      decoration: InputDecoration(
        isDense: true,
        constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: ProMaxTokens.inputBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProMaxTokens.radiusInput),
          borderSide: const BorderSide(color: ProMaxTokens.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProMaxTokens.radiusInput),
          borderSide: const BorderSide(
            color: ProMaxTokens.inputBorderFocused,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _NumberActionButton extends StatelessWidget {
  const _NumberActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(icon, size: 16, color: ProMaxTokens.textPrimary),
        ),
      ),
    );
  }
}
