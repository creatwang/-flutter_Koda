import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/presentation/providers/session_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController(text: 'mor_2314');
  final _passwordController = TextEditingController(text: '83r5^_');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'iPad 商城登录',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: '用户名'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '密码'),
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
                                const SnackBar(content: Text('登录失败，请检查账号密码')),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('登录'),
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
