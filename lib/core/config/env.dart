class Env {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://store.gbuilderchina.com/api',
  );

  ///开发环境：flutter run --dart-define=BASE_URL=https://api.com
  ///生产环境：flutter build apk --dart-define=BASE_URL=https://api.com

  /// 网络日志总开关（配合 --dart-define=NET_TRACE_ENABLED=false 可关闭）。
  /// 说明：拦截器里仍会叠加 kDebugMode 判断，生产构建默认不打印。
  static const bool netTraceEnabled = bool.fromEnvironment(
    'NET_TRACE_ENABLED',
    defaultValue: true,
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
