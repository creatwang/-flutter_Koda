import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/domain/entities/session.dart';
import 'package:groe_app_pad/features/auth/presentation/providers/auth_providers.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, Session>(SessionController.new);

class SessionController extends AsyncNotifier<Session> {
  @override
  FutureOr<Session> build() async {
    final tokenPair = await ref.watch(authRepositoryProvider).readSessionToken();
    return _toSession(tokenPair);
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .login(username: username, password: password);

    return result.when(
      success: (pair) {
        final session = _toSession(pair);
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
    final result = await ref.read(authRepositoryProvider).refreshToken(refreshToken);
    return result.when(
      success: (pair) {
        state = AsyncData(_toSession(pair));
        return pair;
      },
      failure: (_) => null,
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).clearSession();
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
