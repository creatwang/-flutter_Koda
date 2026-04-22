enum CartQuotationFormFieldType { text, number, select }

class CartQuotationConfigDto {
  const CartQuotationConfigDto({required this.formData});

  final List<CartQuotationFormFieldDto> formData;

  factory CartQuotationConfigDto.fromJson(Map<String, dynamic> json) {
    return CartQuotationConfigDto(
      formData: (json['formData'] as List? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => CartQuotationFormFieldDto.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
    );
  }
}

class CartQuotationFormFieldDto {
  const CartQuotationFormFieldDto({
    required this.field,
    required this.title,
    required this.type,
    required this.isRequired,
    required this.defaultValue,
    required this.options,
  });

  final String field;
  final String title;
  final CartQuotationFormFieldType type;
  final bool isRequired;
  final dynamic defaultValue;
  final Map<String, String> options;

  factory CartQuotationFormFieldDto.fromJson(Map<String, dynamic> json) {
    final field = (json['field'] ?? '').toString().trim();
    final title = (json['title'] ?? field).toString().trim();
    final parsedField = field.isEmpty ? title : field;
    final parsedTitle = title.isEmpty ? parsedField : title;
    return CartQuotationFormFieldDto(
      field: parsedField,
      title: parsedTitle,
      type: _parseFieldType(json['type']),
      isRequired: _parseBool(json['required']),
      defaultValue: json['default'],
      options: _parseOptions(json['options']),
    );
  }
}

CartQuotationFormFieldType _parseFieldType(dynamic value) {
  final raw = value?.toString().toLowerCase().trim() ?? '';
  if (raw == 'number') return CartQuotationFormFieldType.number;
  if (raw == 'select') return CartQuotationFormFieldType.select;
  return CartQuotationFormFieldType.text;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return false;
}

Map<String, String> _parseOptions(dynamic value) {
  if (value is! Map) return const <String, String>{};
  final map = <String, String>{};
  for (final entry in value.entries) {
    final key = entry.key.toString().trim();
    if (key.isEmpty) continue;
    map[key] = entry.value?.toString() ?? '';
  }
  return map;
}
