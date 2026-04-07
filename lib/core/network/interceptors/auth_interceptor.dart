import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storageService);

  final SecureStorageService _storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
