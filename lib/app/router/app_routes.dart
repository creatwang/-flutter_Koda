class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const productDetailPattern = '/product/:id';
  static const productScanUniqidsListPath = '/products/scan-uniqids';
  static const preOrder = '/pre-order';
  static const secureStorageDebug = '/debug/secure-storage';

  static String productDetail(int id) => '/product/$id';

  static String productScanUniqidsList(List<String> uniqids) {
    if (uniqids.isEmpty) return productScanUniqidsListPath;
    final query = uniqids
        .map((id) => 'uniqids=${Uri.encodeQueryComponent(id)}')
        .join('&');
    return '$productScanUniqidsListPath?$query';
  }

  static String homeWithTab(String tab) => '/?tab=$tab';
}
