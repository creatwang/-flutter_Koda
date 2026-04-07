import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/domain/repositories/auth_repository.dart';
import 'package:groe_app_pad/features/auth/presentation/providers/auth_providers.dart';
import 'package:groe_app_pad/features/auth/presentation/providers/session_controller.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.loginResult,
    this.storedToken,
  });

  final ApiResult<TokenPair> loginResult;
  TokenPair? storedToken;
  bool clearCalled = false;

  @override
  Future<ApiResult<TokenPair>> login({
    required String username,
    required String password,
  }) async {
    return loginResult.when(
      success: (pair) {
        storedToken = pair;
        return ApiSuccess(pair);
      },
      failure: (e) => ApiFailure(e),
    );
  }

  @override
  Future<ApiResult<TokenPair>> refreshToken(String refreshToken) async {
    if (storedToken == null) {
      return const ApiFailure(AppException('no token'));
    }
    return ApiSuccess(storedToken!);
  }

  @override
  Future<TokenPair?> readSessionToken() async => storedToken;

  @override
  Future<void> clearSession() async {
    clearCalled = true;
    storedToken = null;
  }
}

void main() {
  group('SessionController + FakeAuthRepository', () {
    test('登录成功：不打网络也能测流程', () async {
      final fake = FakeAuthRepository(
        loginResult: const ApiSuccess(
          TokenPair(accessToken: 'access_1', refreshToken: 'refresh_1'),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(sessionControllerProvider.future);
      expect(initial.isAuthenticated, false);

      final ok = await container.read(sessionControllerProvider.notifier).signIn(
            username: 'u',
            password: 'p',
          );
      expect(ok, true);

      final after = container.read(sessionControllerProvider).asData!.value;
      expect(after.isAuthenticated, true);
      expect(after.accessToken, 'access_1');
      expect(after.refreshToken, 'refresh_1');
    });

    test('登录失败：直接验证错误分支', () async {
      final fake = FakeAuthRepository(
        loginResult: const ApiFailure(AppException('bad credentials')),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.future);
      final ok = await container.read(sessionControllerProvider.notifier).signIn(
            username: 'u',
            password: 'wrong',
          );
      expect(ok, false);
      expect(container.read(sessionControllerProvider).hasError, true);
    });
  });
}
