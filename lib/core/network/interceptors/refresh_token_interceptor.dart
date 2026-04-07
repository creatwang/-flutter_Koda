import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:groe_app_pad/core/config/env.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';

typedef RefreshTokenCallback = Future<TokenPair?> Function(String refreshToken);
typedef LogoutCallback = Future<void> Function();

/// 401 自动刷新 token 拦截器：
/// - 仅在收到 401 且当前请求未重试过时触发
/// - 读取 refreshToken 发起刷新
/// - 刷新成功后自动重放原请求
/// - 刷新失败或无 refreshToken 时触发登出
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required Dio dio,
    required SecureStorageService storageService,
    required RefreshTokenCallback onRefreshToken,
    required LogoutCallback onLogout,
  })  : _dio = dio,
        _storageService = storageService,
        _onRefreshToken = onRefreshToken,
        _onLogout = onLogout;

  final Dio _dio;
  final SecureStorageService _storageService;
  final RefreshTokenCallback _onRefreshToken;
  final LogoutCallback _onLogout;

  Future<TokenPair?>? _refreshTask;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestId = '${err.requestOptions.extra['requestId'] ?? '-'}';
    final isUnauthorized = err.response?.statusCode == 401;
    final isRetried = err.requestOptions.extra['retried'] == true;

    // 非 401 或者已经重试过，直接透传，避免死循环。
    if (!isUnauthorized || isRetried) {
      _log('[NET][REFRESH][$requestId] skip isUnauthorized=$isUnauthorized isRetried=$isRetried');
      return handler.next(err);
    }

    // 先读取 refreshToken，缺失则无法恢复会话，直接登出。
    final refreshToken = await _storageService.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _log('[NET][REFRESH][$requestId] no refresh token, logout');
      await _onLogout();
      return handler.next(err);
    }

    // 同时多个 401 时共享同一个刷新任务，避免并发刷新风暴。
    _log('[NET][REFRESH][$requestId] start refresh');
    _refreshTask ??= _onRefreshToken(refreshToken);
    final newTokenPair = await _refreshTask;
    _refreshTask = null;

    // 刷新失败，认为会话已失效。
    if (newTokenPair == null) {
      _log('[NET][REFRESH][$requestId] refresh failed, logout');
      await _onLogout();
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    // 标记已重试，防止再次 401 时无限递归。
    requestOptions.extra['retried'] = true;
    requestOptions.headers['Authorization'] = 'Bearer ${newTokenPair.accessToken}';

    try {
      // 用新 token 重放原请求。
      _log('[NET][REFRESH][$requestId] retry original request');
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      _log('[NET][REFRESH][$requestId] retry failed ${retryErr.type}');
      handler.next(retryErr);
    }
  }

  // 统一日志出口：仅在 Debug 且开启 netTrace 时打印。
  void _log(String message) {
    if (kDebugMode && Env.netTraceEnabled) debugPrint(message);
  }
}
