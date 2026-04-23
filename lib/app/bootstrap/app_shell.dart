import 'dart:ui';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/app/providers/locale_provider.dart';
import 'package:george_pick_mate/app/providers/theme_provider.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/app/router/app_router.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/global_product_scan_fab_widget.dart';
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

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  // 前台回归同步最小间隔，避免频繁切前后台导致重复请求。
  static const Duration _resumeSyncMinInterval = Duration(seconds: 60);
  DateTime? _lastResumeSyncAt;
  // 并发保护：同一时刻只允许一个同步任务执行。
  bool _isResumedSyncing = false;

  @override
  void initState() {
    super.initState();
    // 注册生命周期监听，接收前后台切换事件。
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 页面销毁时移除监听，避免内存泄漏与重复回调。
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flutter 生命周期回调：
    // resumed/inactive/paused/detached 均会进入这里。
    // 仅在 resumed（重新可交互）时做数据同步。
    if (state != AppLifecycleState.resumed) return;
    unawaited(_handleAppResumed());
  }

  Future<void> _handleAppResumed() async {
    // 并发保护：上一次前台同步未完成时直接跳过。
    if (_isResumedSyncing) return;
    final session = ref.read(sessionControllerProvider).asData?.value;
    // 未登录不需要同步用户/站点信息。
    if (session?.isAuthenticated != true) return;

    final now = DateTime.now();
    final lastSyncAt = _lastResumeSyncAt;
    // 节流：短时间频繁切前后台只执行一次同步。
    if (lastSyncAt != null &&
        now.difference(lastSyncAt) < _resumeSyncMinInterval) {
      return;
    }

    _isResumedSyncing = true;
    try {
      await ref.read(sessionSyncProvider.notifier).refreshOnResume();
      _lastResumeSyncAt = DateTime.now();
    } finally {
      _isResumedSyncing = false;
    }
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
    final sessionState = ref.watch(sessionControllerProvider);
    // 路由是否放行取决于会话状态，保证登录态变化后自动重定向。
    final router = buildAppRouter(
      isLoading: sessionState.isLoading,
      isLoggedIn: sessionState.asData?.value.isAuthenticated ?? false,
      navigatorKey: appNavigatorKey,
    );

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
      routerConfig: router,
      builder: (context, child) {
        final currentPath = router.routeInformationProvider.value.uri.path;
        final showGlobalScanFab = currentPath != AppRoutes.login;
        final globalScanFabBottomOffset =
            (kDebugMode && currentPath == AppRoutes.home) ? 146.0 : 14.0;
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
            Breakpoint(start: 750, end: 1023, name: TABLET),
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
            if (showGlobalScanFab)
              GlobalProductScanFabWidget(
                key: ValueKey('scan-fab-$globalScanFabBottomOffset'),
                bottomOffset: globalScanFabBottomOffset,
              ),
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
