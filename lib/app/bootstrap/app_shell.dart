import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/app/providers/locale_provider.dart';
import 'package:groe_app_pad/app/providers/theme_provider.dart';
import 'package:groe_app_pad/app/router/app_router.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/l10n/app_localizations.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/services/app_message_service.dart';
import 'package:groe_app_pad/theme/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../gen/assets.gen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const String _darkBackgroundImageUrl =
      'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=2200&q=80';
  static const String _lightBackgroundImageUrl =
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=2200&q=80';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(appThemeModeProvider);
    final isDark = appThemeMode == AppThemeMode.dark;
    final localeMode = ref.watch(appLocaleModeProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final router = buildAppRouter(
      isLoading: sessionState.isLoading,
      isLoggedIn: sessionState.asData?.value.isAuthenticated ?? false,
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
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      routerConfig: router,
      builder: (context, child) {
        final content = ResponsiveBreakpoints.builder(
          child: Builder(
            builder: (context) {
              final enableScale = !context.isTabletUp;
              return MaxWidthBox(
                maxWidth: 1400,
                child: ResponsiveScaledBox(
                  // < 600：按 1024 基准做等比缩放（开启）
                  // >= 600：不做全局等比缩放（关闭）
                  width: enableScale ? 1024 : null,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          ),
          breakpoints: const [
            Breakpoint(start: 0, end: 599, name: MOBILE),
            // 评判区间
            Breakpoint(start: 600, end: 1023, name: TABLET),
            Breakpoint(start: 1024, end: 3000, name: DESKTOP),
          ],
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Assets.images.detailBgc.image(
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE8ECEF),
              ),
            ),
            // Image.network(
            //   isDark ? _darkBackgroundImageUrl : _lightBackgroundImageUrl,
            //   fit: BoxFit.cover,
            //   errorBuilder: (_, __, ___) => const ColoredBox(
            //     color: Color(0xFFE8ECEF),
            //   ),
            // ),
            // 全局毛玻璃层：对背景图做轻度模糊，增强前景内容可读性。
    /*        ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.16),
                ),
              ),
            ),*/
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
