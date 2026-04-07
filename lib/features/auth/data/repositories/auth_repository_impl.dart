import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:groe_app_pad/features/auth/data/models/auth_token_dto.dart';
import 'package:groe_app_pad/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService storageService,
  })  : _remoteDataSource = remoteDataSource,
        _storageService = storageService;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;

  @override
  Future<ApiResult<TokenPair>> login({
    required String username,
    required String password,
  }) async {
    try {
      final tokenDto = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      final pair = tokenDto.toPair();
      await _storageService.saveTokenPair(pair);
      return ApiSuccess(pair);
    } on DioException catch (e) {
      return ApiFailure(
        AppException(
          e.message ?? 'Login request failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      return ApiFailure(AppException(e.toString()));
    }
  }

  @override
  Future<ApiResult<TokenPair>> refreshToken(String refreshToken) async {
    try {
      final tokenDto = await _remoteDataSource.refreshToken(refreshToken);
      final pair = tokenDto.toPair();
      await _storageService.saveTokenPair(pair);
      return ApiSuccess(pair);
    } catch (e) {
      return ApiFailure(AppException('Refresh token failed: $e'));
    }
  }

  @override
  Future<TokenPair?> readSessionToken() => _storageService.readTokenPair();

  @override
  Future<void> clearSession() => _storageService.clear();
}
