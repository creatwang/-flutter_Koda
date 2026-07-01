import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:george_pick_mate/core/config/env.dart';
import 'package:george_pick_mate/core/storage/secure_storage_service.dart';

/// 认证头注入：读取 [UserInfoBase.token] 写入 `Authorization`。
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storageService);

  final SecureStorageService _storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requestId = '${options.extra['requestId'] ?? '-'}';
    final user = await _storageService.readUserInfoBase();
    final token = user?.token?.trim();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = token;
      _log(
        '[NET][AUTH][$requestId] attach Authorization '
        '${options.method} ${options.path}',
      );
    } else {
      _log(
        '[NET][AUTH][$requestId] no token found '
        '${options.method} ${options.path}',
      );
    }

    handler.next(options);
  }

  void _log(String message) {
    if (kDebugMode && Env.netTraceEnabled) debugPrint(message);
  }
}
