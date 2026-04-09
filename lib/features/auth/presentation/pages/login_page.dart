import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // DummyJSON 演示账号，便于本地直接验证登录流程。
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionState = ref.watch(sessionControllerProvider);
    final isLoading = sessionState.isLoading;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.loginTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: l10n.loginUsername),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.loginPassword),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final ok = await ref
                                .read(sessionControllerProvider.notifier)
                                .signIn(
                                  username: _usernameController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                            if (!context.mounted) return;
                            if (ok) {
                              context.go(AppRoutes.home);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.loginFailed)),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.loginAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
