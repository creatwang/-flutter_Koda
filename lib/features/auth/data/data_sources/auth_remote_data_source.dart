import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/features/auth/data/models/auth_token_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<AuthTokenDto> login({
    required String username,
    required String password,
  }) async {
    final response = await _dioClient.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Some demo APIs return only token; keep refresh token for architecture flow.
      return AuthTokenDto(
        accessToken: data['token']?.toString() ?? 'demo-access-token',
        refreshToken: data['refreshToken']?.toString() ?? 'demo-refresh-token',
      );
    }
    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Invalid login response format',
    );
  }

  Future<AuthTokenDto> refreshToken(String refreshToken) async {
    // Demo fallback: keep flow available even without backend refresh endpoint.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return AuthTokenDto(
      accessToken: 'refreshed-access-$refreshToken',
      refreshToken: refreshToken,
    );
  }
}
