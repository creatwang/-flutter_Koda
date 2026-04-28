import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/providers/locale_provider.dart';
import 'package:george_pick_mate/app/providers/theme_provider.dart';
import 'package:george_pick_mate/app/router/app_router.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/auth/models/session.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/dismiss_keyboard_on_tap_widget.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';
import 'package:george_pick_mate/theme/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../gen/assets.gen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _routerSessionState = _RouterSessionState();
  late final GoRouter _router;
  late final ProviderSubscription<AsyncValue<Session>> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _syncRouterSessionState(ref.read(sessionControllerProvider));
    _router = buildAppRouter(
      isLoading: () => _routerSessionState.isLoading,
      isLoggedIn: () => _routerSessionState.isLoggedIn,
      refreshListenable: _routerSessionState,
      navigatorKey: appNavigatorKey,
    );
    _sessionSubscription = ref.listenManual<AsyncValue<Session>>(
      sessionControllerProvider,
      (_, next) => _syncRouterSessionState(next),
    );
  }

  @override
  void dispose() {
    _sessionSubscription.close();
    _routerSessionState.dispose();
    super.dispose();
  }

  void _syncRouterSessionState(AsyncValue<Session> sessionState) {
    _routerSessionState.update(
      isLoading: sessionState.isLoading,
      isLoggedIn: sessionState.asData?.value.isAuthenticated ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 全局会话过期处理：由网络层回调后统一清会话并回登录态。
    registerSessionExpiredHandler(
      () => ref.read(sessionControllerProvider.notifier).signOut(),
    );

    final appThemeMode = ref.watch(appThemeModeProvider);
    final isDark = appThemeMode == AppThemeMode.dark;
    final localeMode = ref.watch(appLocaleModeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: buildAppTheme(appThemeMode),
      locale: localeMode.localeOrNull,
      // 国际化资源加载器：
      // 1) AppLocalizations.delegate 负责加载 ARB 生成的业务文案
      // 2) Global*Localizations 负责 Flutter 组件内置文案与地区化能力
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 应用支持的语言列表（系统语言会在这里做匹配与回退）。
      supportedLocales: const [Locale('en'), Locale('zh')],
      routerConfig: _router,
      builder: (context, child) {
        // iPad/桌面保持固定最大宽度，小屏按 1024 设计稿等比缩放。
        final content = ResponsiveBreakpoints.builder(
          child: Builder(
            builder: (context) {
              final enableScale = !context.isTabletUp;
              return MaxWidthBox(
                maxWidth: 1400,
                child: ClipRect(
                  child: ResponsiveScaledBox(
                    // < 600：按 1024 基准做等比缩放（开启）
                    // >= 600：不做全局等比缩放（关闭）
                    width: enableScale ? 1024 : null,
                    child: DismissKeyboardOnTap(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              );
            },
          ),
          breakpoints: const [
            Breakpoint(start: 0, end: 599, name: MOBILE),
            // 评判区间
            Breakpoint(start: 750, end: 1024, name: TABLET),
            Breakpoint(start: 1024, end: 3000, name: DESKTOP),
          ],
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            // 分层背景：底图 + 毛玻璃 + 细节图 + 渐变遮罩。
            Assets.images.mainBgc.image(
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFFE8ECEF)),
            ),
            // 全局毛玻璃层：对背景图做轻度模糊，增强前景内容可读性。
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.16),
                ),
              ),
            ),
            Assets.images.detailBgc.image(
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFFE8ECEF)),
            ),
            // Image.network(
            //   isDark ? _darkBackgroundImageUrl : _lightBackgroundImageUrl,
            //   fit: BoxFit.cover,
            //   errorBuilder: (_, __, ___) => const ColoredBox(
            //     color: Color(0xFFE8ECEF),
            //   ),
            // ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? Colors.black.withValues(alpha: 0.32)
                        : Colors.white.withValues(alpha: 0.20),
                    isDark
                        ? Colors.black.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.10),
                  ],
                ),
              ),
            ),
            content,
            /*     Positioned(
              right: 14,
              bottom: 14,
              child: SafeArea(
                child: FloatingActionButton.small(
                  heroTag: 'global-theme-toggle',
                  backgroundColor: isDark
                      ? Colors.black.withValues(alpha: 0.58)
                      : Colors.white.withValues(alpha: 0.74),
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  onPressed: () => ref.read(appThemeModeProvider.notifier).toggle(),
                  child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                ),
              ),
            ),*/
          ],
        );
      },
    );
  }
}

class _RouterSessionState extends ChangeNotifier {
  bool isLoading = true;
  bool isLoggedIn = false;

  void update({required bool isLoading, required bool isLoggedIn}) {
    if (this.isLoading == isLoading && this.isLoggedIn == isLoggedIn) {
      return;
    }
    this.isLoading = isLoading;
    this.isLoggedIn = isLoggedIn;
    notifyListeners();
  }
}
