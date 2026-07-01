import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/core/storage/token_pair.dart';
import 'package:george_pick_mate/features/auth/controllers/login_remember_providers.dart';
import 'package:george_pick_mate/features/auth/services/auth_services.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionController + FakeAuthApi', () {
    test('登录成功：更新 storeHost 与 token', () async {
      final container = ProviderContainer(
        overrides: [
          authLoginServiceProvider.overrideWithValue(
            ({required username, required password}) async {
              const pair = TokenPair(
                token: 'access_1',
                storeHost: 'store.gbuilderchina.com',
              );
              return const ApiSuccess(pair);
            },
          ),
          authClearTokenServiceProvider.overrideWithValue(() async {}),
          persistRememberedLoginFormProvider.overrideWithValue(
            ({
              required username,
              required password,
              required shouldRememberPassword,
            }) async {},
          ),
        ],
      );
      addTearDown(container.dispose);

      // 不 await build()：单测环境 SecureStorage 平台通道可能阻塞。
      final error = await container.read(sessionControllerProvider.notifier).signIn(
            username: 'u',
            password: 'p',
          );
      expect(error, isNull);

      final after = container.read(sessionControllerProvider).asData!.value;
      expect(after.isAuthenticated, true);
      expect(after.storeHost, 'store.gbuilderchina.com');
      expect(after.token, 'access_1');
    });

    test('登录失败：返回错误文案且不写 AsyncError', () async {
      final container = ProviderContainer(
        overrides: [
          authLoginServiceProvider.overrideWithValue(
            ({required username, required password}) async {
              return const ApiFailure(AppException('bad credentials'));
            },
          ),
          authClearTokenServiceProvider.overrideWithValue(() async {}),
          persistRememberedLoginFormProvider.overrideWithValue(
            ({
              required username,
              required password,
              required shouldRememberPassword,
            }) async {},
          ),
        ],
      );
      addTearDown(container.dispose);

      final error = await container.read(sessionControllerProvider.notifier).signIn(
            username: 'u',
            password: 'wrong',
          );
      expect(error, 'bad credentials');
      expect(container.read(sessionControllerProvider).hasError, false);
    });
  });
}
