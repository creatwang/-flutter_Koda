import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:groe_app_pad/core/config/env.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';

/// 认证头注入拦截器：
/// - 在请求发出前读取本地 accessToken
/// - 若 token 存在则写入 `Authorization: Bearer <token>`
/// - 配合 requestId 输出日志，便于定位“为什么没带鉴权头”
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storageService);

  final SecureStorageService _storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requestId = '${options.extra['requestId'] ?? '-'}';
    // 请求前从安全存储读取 access token。

    final companyId = await _storageService.getCompanyId();
    if (companyId == null) {
      _log('[NET][AUTH][$requestId] 没有CompanyId ${options.method} ${options.path}');
    } else {
      final token = await _storageService.getTokenByCompanyId(companyId);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = token;
        _log('[NET][AUTH][$requestId] attach Authorization 注入 token ${options.method} ${options.path}');
      } else {
        // 没有 token 不是异常场景（比如未登录），只记录日志。
        _log('[NET][AUTH][$requestId] no token found ${options.method} ${options.path}');
      }
    }

    handler.next(options);
  }

  // 统一日志出口：仅在 Debug 且开启 netTrace 时打印。
  void _log(String message) {
    if (kDebugMode && Env.netTraceEnabled) debugPrint(message);
  }
}
