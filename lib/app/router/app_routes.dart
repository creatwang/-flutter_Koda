class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const productDetailPattern = '/product/:id';
  static const secureStorageDebug = '/debug/secure-storage';

  static String productDetail(int id) => '/product/$id';

  static String homeWithTab(String tab) => '/?tab=$tab';
}
