class Env {
  /// 未登录 / 登出后的默认 API 根地址，也是路径前缀的来源。
  ///
  /// - 测试：`.../testapi`（默认）
  /// - 正式：`.../api`（构建时传入）
  ///
  /// 登录/切站后只替换 host，路径前缀始终与 [baseUrl] 一致：
  /// `https://{store_domain}{apiPathPrefix}`。
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://store.gbuilderchina.com/testapi',
  );

  /// 测试：`flutter run`
  /// （默认 `BASE_URL=.../testapi`）
  ///
  /// 正式：`flutter build apk --dart-define=BASE_URL=https://store.example.com/api`
  ///
  /// Web 调试同理，通过 [baseUrl] 区分 `/testapi` 与 `/api`。

  /// 从 [baseUrl] 解析出的 API 路径前缀（如 `/api`、`/testapi`）。
  static String get apiPathPrefix {
    final path = Uri.parse(baseUrl).path;
    return path.isEmpty ? '/api' : path;
  }

  /// [baseUrl] 的 scheme，切站时与路径前缀一并复用。
  static String get apiScheme => Uri.parse(baseUrl).scheme;

  /// 网络日志总开关（配合 --dart-define=NET_TRACE_ENABLED=false 可关闭）。
  /// 说明：拦截器里仍会叠加 kDebugMode 判断，生产构建默认不打印。
  static const bool netTraceEnabled = bool.fromEnvironment(
    'NET_TRACE_ENABLED',
    defaultValue: true,
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
