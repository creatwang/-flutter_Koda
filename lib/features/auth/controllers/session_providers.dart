import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/services/auth_services.dart';
import 'package:groe_app_pad/features/auth/models/session.dart';

import '../../../core/services/core_services.dart';

final sessionControllerProvider = AsyncNotifierProvider<SessionController, Session>(SessionController.new);

class SessionController extends AsyncNotifier<Session> {
  @override
  FutureOr<Session> build() async {
    final tokenPair = await ref.watch(authReadTokenServiceProvider)();
    return _toSession(tokenPair);
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authLoginServiceProvider)(
      username: username,
      password: password,
    );

    return result.when(
      success: (pair) {
        final session = _toSession(pair);
        /**
         * @Description 当你把 state 设置为 AsyncData 时，UI 监听者（ConsumerWidget）会自动监听到这个变化，并根据新的数据重新构建页面。
         * @date 2026/04/08 18:06:39
         */
        state = AsyncData(session);
        return true;
      },
      failure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return false;
      },
    );
  }

  Future<TokenPair?> refreshToken(String refreshToken) async {
    final result = await ref.read(authRefreshServiceProvider)(refreshToken);
    return result.when(
      success: (pair) {
        state = AsyncData(_toSession(pair));
        return pair;
      },
      failure: (_) => null,
    );
  }

  Future<void> signOut() async {
    await ref.read(authClearTokenServiceProvider)();
    state = const AsyncData(Session(isAuthenticated: false));
  }

  Session _toSession(TokenPair? pair) {
    if (pair == null) return const Session(isAuthenticated: false);
    return Session(
      isAuthenticated: true,
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );
  }
}
