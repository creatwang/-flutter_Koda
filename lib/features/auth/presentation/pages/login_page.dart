import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/controllers/login_remember_providers.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/dismiss_keyboard_on_tap_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _rememberMe = true;
  final bool _isRegister = false;

  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=2200&q=80';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateRememberedForm();
    });
  }

  Future<void> _hydrateRememberedForm() async {
    final dto = await ref.read(rememberedLoginFormProvider.future);
    if (!mounted || dto == null) return;
    setState(() {
      _usernameController.text = dto.username;
      if (dto.hasSavedPassword) {
        _passwordController.text = dto.password ?? '';
        _rememberMe = true;
      } else {
        _rememberMe = false;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionState = ref.watch(sessionControllerProvider);
    final isLoading = sessionState.isLoading;
    final isCompact = MediaQuery.of(context).size.width < 860;

    return DismissKeyboardOnTap(
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const NetworkImage(_heroImageUrl),
              fit: BoxFit.cover,
              onError: (_, __) {},
            ),
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 760),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isCompact
                        ? _buildRightPanel(context, l10n, isLoading, compact: true)
                        : Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: const NetworkImage(_heroImageUrl),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              ),
                            ),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: _buildRightPanel(context, l10n, isLoading),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(
    BuildContext context,
    AppLocalizations l10n,
    bool isLoading, {
    bool compact = false,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: compact ? 0.24 : 0.20),
                Colors.white.withValues(alpha: compact ? 0.16 : 0.12),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  38,
                  34,
                  38,
                  34 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 68),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 80),
                      Text(
                        _isRegister ? l10n.authRegisterHeading : l10n.authLoginHeading,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36 * 0.62,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                     /*后面该代码不要删除下面注释的代码*/
                     /* const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _isRegister ? l10n.authHaveAccountHint : l10n.authNewHereHint,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => setState(() => _isRegister = !_isRegister),
                            child: Text(
                              _isRegister ? l10n.authLoginAction : l10n.authRegisterAction,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.98),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white.withValues(alpha: 0.98),
                              ),
                            ),
                          ),
                        ],
                      ),*/
                      const SizedBox(height: 12),
                      const SizedBox(height: 28),
                      _fieldLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 8),
                      _glassField(
                        controller: _usernameController,
                        hint: 'name@firm.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _fieldLabel('PASSWORD'),
                          const Spacer(),
                          Text(
                            l10n.authForgotPassword,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _glassField(
                        controller: _passwordController,
                        obscureText: true,
                        hint: '********',
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction:
                            _isRegister ? TextInputAction.next : TextInputAction.done,
                      ),
                      if (_isRegister) ...[
                        const SizedBox(height: 16),
                        _fieldLabel(l10n.authConfirmPasswordLabel.toUpperCase()),
                        const SizedBox(height: 8),
                        _glassField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          hint: '********',
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.85,
                            child: Checkbox(
                              value: _rememberMe,
                              fillColor: WidgetStateProperty.resolveWith(
                                (_) => Colors.white.withValues(alpha: 0.95),
                              ),
                              checkColor: Colors.black,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                            ),
                          ),
                          Expanded(
                            child: Text(
                              l10n.authRememberMe,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.88),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => _handleSubmit(context, l10n),
                          child: isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isRegister ? l10n.authRegisterAction : l10n.loginAction),
                        ),
                      ),
                     /* const SizedBox(height: 24),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'By signing in, you agree to our Terms of Service and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Center(
                        child: Text(
                          '© 2024 The Digital Curator. All rights reserved.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 10,
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context, AppLocalizations l10n) async {
    if (_isRegister) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final confirm = _confirmPasswordController.text.trim();
      if (username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authRegisterUsernameRequired)),
        );
        return;
      }
      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authRegisterPasswordMinLength)),
        );
        return;
      }
      if (confirm.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authRegisterPasswordMinLength)),
        );
        return;
      }
      if (password != confirm) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authPasswordMismatch)),
        );
        return;
      }
      final ok = await ref.read(sessionControllerProvider.notifier).register(
            username: username,
            password: password,
            passwordConfirm: confirm,
            shouldRememberPassword: _rememberMe,
          );
      if (!context.mounted) return;
      if (ok) {
        context.go(AppRoutes.home);
      } else {
        final message = ref.read(sessionControllerProvider).maybeWhen(
              error: (e, _) => e is AppException ? e.message : null,
              orElse: () => null,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? l10n.authRegisterFailed),
          ),
        );
      }
      return;
    }

    final ok = await ref.read(sessionControllerProvider.notifier).signIn(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          shouldRememberPassword: _rememberMe,
        );
    if (!context.mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginFailed)),
      );
    }
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.86),
        fontSize: 10.5,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.18),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.34)),
        ),
      ),
    );
  }
}
