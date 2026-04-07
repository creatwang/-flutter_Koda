import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';

abstract interface class AuthRepository {
  Future<ApiResult<TokenPair>> login({
    required String username,
    required String password,
  });

  Future<ApiResult<TokenPair>> refreshToken(String refreshToken);

  Future<TokenPair?> readSessionToken();

  Future<void> clearSession();
}
