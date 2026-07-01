const String _scanHostKeySeparator = '\x1e';

String encodeProductDetailProviderKey({
  required int productId,
  String? scanHost,
}) {
  final host = scanHost?.trim();
  if (host == null || host.isEmpty) return '$productId';
  return '$productId$_scanHostKeySeparator$host';
}

({int productId, String? scanHost}) decodeProductDetailProviderKey(String key) {
  final parts = key.split(_scanHostKeySeparator);
  final id = int.tryParse(parts.first) ?? 0;
  if (parts.length < 2) {
    return (productId: id, scanHost: null);
  }
  final host = parts.sublist(1).join(_scanHostKeySeparator).trim();
  return (productId: id, scanHost: host.isEmpty ? null : host);
}
