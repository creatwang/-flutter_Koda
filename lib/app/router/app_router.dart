import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/presentation/pages/login_page.dart';
import 'package:groe_app_pad/features/auth/presentation/pages/splash_page.dart';
import 'package:groe_app_pad/features/auth/presentation/providers/session_controller.dart';
import 'package:groe_app_pad/features/home/presentation/pages/home_page.dart';
import 'package:groe_app_pad/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionControllerProvider);

  final bool isLoading = sessionState.isLoading;
  final bool isLoggedIn = sessionState.asData?.value.isAuthenticated ?? false;

  return GoRouter(
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
});
