import 'dart:async';

import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';

typedef RefreshTokenCallback = Future<TokenPair?> Function(String refreshToken);
typedef LogoutCallback = Future<void> Function();

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
    final isUnauthorized = err.response?.statusCode == 401;
    final isRetried = err.requestOptions.extra['retried'] == true;

    if (!isUnauthorized || isRetried) {
      return handler.next(err);
    }

    final refreshToken = await _storageService.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _onLogout();
      return handler.next(err);
    }

    _refreshTask ??= _onRefreshToken(refreshToken);
    final newTokenPair = await _refreshTask;
    _refreshTask = null;

    if (newTokenPair == null) {
      await _onLogout();
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    requestOptions.extra['retried'] = true;
    requestOptions.headers['Authorization'] = 'Bearer ${newTokenPair.accessToken}';

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }
}
