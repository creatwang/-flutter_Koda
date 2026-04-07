import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:groe_app_pad/core/providers/core_providers.dart';
import 'package:groe_app_pad/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:groe_app_pad/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:groe_app_pad/features/auth/domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    storageService: ref.watch(secureStorageServiceProvider),
  );
});

final authDioProvider = Provider<Dio>((ref) {
  final dio = ref.watch(baseDioProvider);
  final storage = ref.watch(secureStorageServiceProvider);

  final hasRefreshInterceptor = dio.interceptors.any(
    (interceptor) => interceptor is RefreshTokenInterceptor,
  );
  if (!hasRefreshInterceptor) {
    dio.interceptors.add(
      RefreshTokenInterceptor(
        dio: dio,
        storageService: storage,
        onRefreshToken: (refreshToken) async {
          final result = await ref.read(authRepositoryProvider).refreshToken(refreshToken);
          return result.when(
            success: (pair) => pair,
            failure: (_) => null,
          );
        },
        onLogout: () async {
          await ref.read(authRepositoryProvider).clearSession();
        },
      ),
    );
  }

  return dio;
});

final authDioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.watch(authDioProvider)),
);
