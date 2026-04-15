import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/services/auth_services.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';

void main() {
  group('SessionController + FakeAuthApi', () {
    test('登录成功：不打网络也能测流程', () async {
      final container = ProviderContainer(
        overrides: [
          authLoginServiceProvider.overrideWithValue(
            ({required username, required password}) async {
              const pair = TokenPair(accessToken: 'access_1', refreshToken: 'refresh_1');
              return const ApiSuccess(pair);
            },
          ),
          authClearTokenServiceProvider.overrideWithValue(() async {}),
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
    });

    test('登录失败：直接验证错误分支', () async {
      final container = ProviderContainer(
        overrides: [
          authLoginServiceProvider.overrideWithValue(
            ({required username, required password}) async {
              return const ApiFailure(AppException('bad credentials'));
            },
          ),
          authReadTokenServiceProvider.overrideWithValue(() async => null),
          authClearTokenServiceProvider.overrideWithValue(() async {}),
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
