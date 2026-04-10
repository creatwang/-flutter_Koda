import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/models/session.dart';
import 'package:groe_app_pad/features/auth/services/auth_services.dart';

import '../../../core/platform_services/network_clients.dart';

final sessionControllerProvider = AsyncNotifierProvider<SessionController, Session>(SessionController.new);

class SessionController extends AsyncNotifier<Session> {
  @override
  FutureOr<Session> build() async {
    final companyId = await ref.watch(authReadTokenServiceProvider)();
    return _toSession(companyId);
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
      success: (TokenPair pair) {
        state = AsyncData(
          Session(
            isAuthenticated: true,
            token: pair.token,
            companyId: pair.companyId,
          ),
        );
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
      success: (pair) async {
        Session session = await _toSession(pair.companyId);
        state = AsyncData(session);
        return pair;
      },
      failure: (_) => null,
    );
  }

  Future<void> signOut() async {
    await ref.read(authClearTokenServiceProvider)();
    state = const AsyncData(Session(isAuthenticated: false));
  }

  FutureOr<Session> _toSession(String? companyId) async {
    if (companyId == null || companyId.isEmpty) {
      return const Session(isAuthenticated: false);
    }
    final token = await secureStorageService.getTokenByCompanyId(companyId);
    return Session(
      isAuthenticated: true,
      companyId: companyId,
      token: token
    );
  }
}
