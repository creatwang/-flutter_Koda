class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const productDetailPattern = '/product/:id';
  static const productScanUniqidsListPath = '/products/scan-uniqids';
  static const preOrder = '/pre-order';
  static const secureStorageDebug = '/debug/secure-storage';

  static const String scanHostQueryKey = 'scanHost';
  static const String qrcodeKeyQueryKey = 'qrcode_key';

  static String productDetail(int id, {String? scanHost}) {
    if (scanHost == null || scanHost.trim().isEmpty) {
      return '/product/$id';
    }
    return '/product/$id?$scanHostQueryKey=${Uri.encodeQueryComponent(scanHost.trim())}';
  }

  static String productScanUniqidsList(
    List<String> uniqids, {
    String? scanHost,
    String? qrcodeKey,
  }) {
    final params = <String>[];
    if (scanHost != null && scanHost.trim().isNotEmpty) {
      params.add(
        '$scanHostQueryKey=${Uri.encodeQueryComponent(scanHost.trim())}',
      );
    }
    final normalizedQrcodeKey = qrcodeKey?.trim();
    if (normalizedQrcodeKey != null && normalizedQrcodeKey.isNotEmpty) {
      params.add(
        '$qrcodeKeyQueryKey=${Uri.encodeQueryComponent(normalizedQrcodeKey)}',
      );
    }
    if (uniqids.isEmpty) {
      return params.isEmpty
          ? productScanUniqidsListPath
          : '$productScanUniqidsListPath?${params.join('&')}';
    }
    params.addAll(
      uniqids.map((id) => 'uniqids=${Uri.encodeQueryComponent(id)}'),
    );
    return '$productScanUniqidsListPath?${params.join('&')}';
  }

  static String? scanHostFromUri(Uri uri) {
    final raw = uri.queryParameters[scanHostQueryKey]?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static String homeWithTab(String tab) => '/?tab=$tab';
}
