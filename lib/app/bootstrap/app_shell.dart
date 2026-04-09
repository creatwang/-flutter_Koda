import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/app/providers/locale_provider.dart';
import 'package:groe_app_pad/app/router/app_router.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/l10n/app_localizations.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeMode = ref.watch(appLocaleModeProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final router = buildAppRouter(
      isLoading: sessionState.isLoading,
      isLoggedIn: sessionState.asData?.value.isAuthenticated ?? false,
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
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
        return ResponsiveBreakpoints.builder(
          child: Builder(
            builder: (context) {
              final enableScale = !context.isTabletUp;
              return MaxWidthBox(
                maxWidth: 1400,
                child: ResponsiveScaledBox(
                  // enableScale == true（小屏）=> 传 1024，开启等比缩放
                  // enableScale == false（平板及以上）=> 传 null，不做缩放
                  width: enableScale ? 1024 : null,
                  child: child!,
                ),
              );
            },
          ),
          breakpoints: const [
            Breakpoint(start: 0, end: 599, name: MOBILE),
            Breakpoint(start: 600, end: 1023, name: TABLET),
            Breakpoint(start: 1024, end: 3000, name: DESKTOP),
          ],
        );
      },
    );
  }
}
