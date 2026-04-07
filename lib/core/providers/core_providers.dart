import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:groe_app_pad/core/config/env.dart';
import 'package:groe_app_pad/core/network/interceptors/auth_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/memory_cache_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/request_trace_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/retry_interceptor.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';

// 为了测试写的
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(ref.watch(flutterSecureStorageProvider)),
);

final baseDioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    RequestTraceInterceptor(),
    MemoryCacheInterceptor(ttl: const Duration(minutes: 2)),
    RetryInterceptor(dio),
  ]);
  return dio;
});

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.watch(baseDioProvider)),
);
