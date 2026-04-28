import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/cart/presentation/pages/cart_page.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/profile/presentation/pages/profile_page.dart';
import 'package:george_pick_mate/features/product/presentation/pages/product_list_page.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/global_product_scan_fab_widget.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/adaptive_scaffold.dart';
import 'package:george_pick_mate/shared/widgets/frosted_bottom_menu.dart';
import 'package:george_pick_mate/shared/widgets/header_menu_button.dart';

import 'home_start.dart';

enum HomeSection { products, cart, start, profile }

String _homeLocationForSection(HomeSection section) => switch (section) {
  HomeSection.start => AppRoutes.home,
  HomeSection.products => AppRoutes.homeWithTab('products'),
  HomeSection.cart => AppRoutes.homeWithTab('cart'),
  HomeSection.profile => AppRoutes.homeWithTab('profile'),
};

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLogoutLoading = false;
  bool _showSwitchSiteEntry = false;
  Timer? _profileSwitchSiteHoldTimer;

  @override
  void dispose() {
    _profileSwitchSiteHoldTimer?.cancel();
    super.dispose();
  }

  static const Duration _kProfileSwitchSiteHoldDuration = Duration(seconds: 5);

  void _beginProfileSwitchSiteHold() {
    _profileSwitchSiteHoldTimer?.cancel();
    _profileSwitchSiteHoldTimer = Timer(_kProfileSwitchSiteHoldDuration, () {
      _profileSwitchSiteHoldTimer = null;
      if (!mounted) return;
      setState(() => _showSwitchSiteEntry = !_showSwitchSiteEntry);
    });
  }

  void _cancelProfileSwitchSiteHold() {
    _profileSwitchSiteHoldTimer?.cancel();
    _profileSwitchSiteHoldTimer = null;
  }

  HomeSection _tabToSection(String? tab) {
    return switch (tab) {
      'cart' => HomeSection.cart,
      'profile' => HomeSection.profile,
      'products' => HomeSection.products,
      _ => HomeSection.start,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    final section = _tabToSection(tab);
    final cartCount = section == HomeSection.cart
        ? ref.watch(cartListBadgeCountProvider)
        : 0;

    void goSection(HomeSection next) {
      context.go(_homeLocationForSection(next));
    }

    final Widget body = switch (section) {
      HomeSection.products => const ProductListPage(),
      // HomeSection.products => const ProductDetailPage(productId: 117276),
      HomeSection.cart => const CartPage(),
      HomeSection.start => HomeStartPage(
        showSwitchSiteEntry: _showSwitchSiteEntry,
        onStartShopping: () => goSection(HomeSection.products),
      ),
      HomeSection.profile => ProfilePage(
        showSwitchSiteEntry: _showSwitchSiteEntry,
      ),
    };

    return AdaptiveScaffold(
      title: l10n.appTitle,
      automaticallyImplyLeading: false,
      extendBody: section == HomeSection.start,
      actions: [
        HeaderMenuButton(
          label: 'Home',
          icon: Icons.storefront,
          selected: section == HomeSection.start,
          onTap: () => goSection(HomeSection.start),
        ),
        HeaderMenuButton(
          label: l10n.homeProducts,
          icon: Icons.storefront,
          selected: section == HomeSection.products,
          onTap: () => goSection(HomeSection.products),
        ),
        HeaderMenuButton(
          label: l10n.homeCartWithCount(cartCount),
          icon: Icons.shopping_cart_outlined,
          selected: section == HomeSection.cart,
          onTap: () => goSection(HomeSection.cart),
        ),
        Listener(
          onPointerDown: (_) => _beginProfileSwitchSiteHold(),
          onPointerUp: (_) => _cancelProfileSwitchSiteHold(),
          onPointerCancel: (_) => _cancelProfileSwitchSiteHold(),
          child: HeaderMenuButton(
            label: 'Profile',
            icon: Icons.person_outline,
            selected: section == HomeSection.profile,
            onTap: () => goSection(HomeSection.profile),
          ),
        ),
        IconButton(
          tooltip: l10n.commonLogout,
          onPressed: _isLogoutLoading
              ? null
              : () async {
                  setState(() => _isLogoutLoading = true);
                  final result = await ref
                      .read(sessionControllerProvider.notifier)
                      .signOutWithRemoteLogout();
                  if (!context.mounted) return;
                  setState(() => _isLogoutLoading = false);
                  result.when(
                    success: (_) => context.go(AppRoutes.login),
                    failure: (exception) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: SelectableText.rich(
                            TextSpan(
                              text: exception.message,
                              style: const TextStyle(
                                color: Color(0xFFFFD7D8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
          icon: _isLogoutLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
        ),
      ],
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              heroTag: 'home_secure_storage_debug_fab',
              tooltip: 'Secure Storage Debug',
              onPressed: () => context.push(AppRoutes.secureStorageDebug),
              child: const Icon(Icons.bug_report_outlined),
            )
          : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            top: section != HomeSection.start,
            bottom: false,
            child: body,
          ),
          const GlobalProductScanFabWidget(bottomOffset: 14),
        ],
      ),
      bottomBarVisibility: AdaptiveBottomBarVisibility.always,
      bottomNavigationBar: FrostedBottomMenu(
        items: [
          FrostedBottomMenuItem(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: section == HomeSection.start,
            onTap: () => goSection(HomeSection.start),
          ),
          FrostedBottomMenuItem(
            icon: Icons.inventory_2_outlined,
            label: l10n.homeProducts,
            selected: section == HomeSection.products,
            onTap: () => goSection(HomeSection.products),
          ),
          FrostedBottomMenuItem(
            icon: Icons.shopping_bag_outlined,
            label: l10n.homeCart,
            selected: section == HomeSection.cart,
            onTap: () => goSection(HomeSection.cart),
          ),
          FrostedBottomMenuItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: section == HomeSection.profile,
            onTap: () => goSection(HomeSection.profile),
            onPointerDown: (_) => _beginProfileSwitchSiteHold(),
            onPointerUp: (_) => _cancelProfileSwitchSiteHold(),
            onPointerCancel: (_) => _cancelProfileSwitchSiteHold(),
          ),
        ],
      ),
    );
  }
}
