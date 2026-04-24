import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/presentation/pages/login_page.dart';
import 'package:george_pick_mate/features/auth/presentation/pages/secure_storage_debug_page.dart';
import 'package:george_pick_mate/features/auth/presentation/pages/splash_page.dart';
import 'package:george_pick_mate/features/cart/presentation/pages/pre_order_page.dart';
import 'package:george_pick_mate/features/home/presentation/pages/home_page.dart';
import 'package:george_pick_mate/features/product/presentation/pages/product_detail_page.dart';

GoRouter buildAppRouter({
  required bool isLoading,
  required bool isLoggedIn,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, state) => HomePage(initialTab: state.uri.queryParameters['tab']),
      ),
      GoRoute(
        path: AppRoutes.productDetailPattern,
        builder: (_, state) => ProductDetailPage(
          productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.preOrder,
        builder: (_, __) => const PreOrderPage(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.secureStorageDebug,
          builder: (_, __) => const SecureStorageDebugPage(),
        ),
    ],
    // 初始化路由
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final atSplash = state.matchedLocation == AppRoutes.splash;
      final atLogin = state.matchedLocation == AppRoutes.login;

      if (isLoading) {
        return atSplash ? null : AppRoutes.splash;
      }

      if (!isLoggedIn) {
        return atLogin ? null : AppRoutes.login;
      }

      if (atLogin || atSplash) return AppRoutes.home;
      return null;
    },
  );
}
