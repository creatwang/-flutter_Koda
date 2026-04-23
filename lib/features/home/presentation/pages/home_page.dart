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
import 'package:george_pick_mate/features/product/presentation/widgets/product_scan_fab_flow.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/adaptive_scaffold.dart';
import 'package:george_pick_mate/shared/widgets/frosted_bottom_menu.dart';
import 'package:george_pick_mate/shared/widgets/header_menu_button.dart';

import '../../../product/presentation/pages/product_category_page.dart';

enum HomeSection { products, cart, productCategory, profile }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.initialTab});

  final String? initialTab;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  HomeSection _section = HomeSection.products;
  bool _isLogoutLoading = false;
  bool _showSwitchSiteEntry = false;
  Timer? _profileSwitchSiteHoldTimer;

  @override
  void initState() {
    super.initState();
    _section = _tabToSection(widget.initialTab);
  }

  @override
  void dispose() {
    _profileSwitchSiteHoldTimer?.cancel();
    super.dispose();
  }

  static const Duration _kProfileSwitchSiteHoldDuration = Duration(seconds: 10);

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
      _ => HomeSection.products,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cartCount = _section == HomeSection.cart
        ? ref.watch(cartListBadgeCountProvider)
        : 0;

    final Widget body = switch (_section) {
      HomeSection.products => const ProductListPage(),
      // HomeSection.products => const ProductDetailPage(productId: 117276),
      HomeSection.cart => const CartPage(),
      HomeSection.productCategory => const ProductCategoryPage(),
      HomeSection.profile => ProfilePage(
        showSwitchSiteEntry: _showSwitchSiteEntry,
      ),
    };

    return AdaptiveScaffold(
      title: l10n.appTitle,
      automaticallyImplyLeading: false,
      actions: [
        HeaderMenuButton(
          label: l10n.homeCategory,
          icon: Icons.storefront,
          selected: _section == HomeSection.productCategory,
          onTap: () => setState(() => _section = HomeSection.productCategory),
        ),
        HeaderMenuButton(
          label: l10n.homeProducts,
          icon: Icons.storefront,
          selected: _section == HomeSection.products,
          onTap: () => setState(() => _section = HomeSection.products),
        ),
        HeaderMenuButton(
          label: l10n.homeCartWithCount(cartCount),
          icon: Icons.shopping_cart_outlined,
          selected: _section == HomeSection.cart,
          onTap: () => setState(() => _section = HomeSection.cart),
        ),
        Listener(
          onPointerDown: (_) => _beginProfileSwitchSiteHold(),
          onPointerUp: (_) => _cancelProfileSwitchSiteHold(),
          onPointerCancel: (_) => _cancelProfileSwitchSiteHold(),
          child: HeaderMenuButton(
            label: 'Profile',
            icon: Icons.person_outline,
            selected: _section == HomeSection.profile,
            onTap: () => setState(() => _section = HomeSection.profile),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (kDebugMode) ...[
            FloatingActionButton.small(
              heroTag: 'home_secure_storage_debug_fab',
              tooltip: 'Secure Storage Debug',
              onPressed: () => context.push(AppRoutes.secureStorageDebug),
              child: const Icon(Icons.bug_report_outlined),
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton.small(
            heroTag: 'product_scan_qr_home_fab',
            tooltip: l10n.productScanTooltip,
            backgroundColor: Colors.black,
            onPressed: () async {
              await runProductQrScanFlow(ref: ref, context: context);
            },
            child: const Icon(Icons.qr_code_scanner_rounded, size: 20),
          ),
        ],
      ),
      body: SafeArea(bottom: false, child: body),
      bottomBarVisibility: AdaptiveBottomBarVisibility.always,
      bottomNavigationBar: FrostedBottomMenu(
        items: [
          FrostedBottomMenuItem(
            icon: Icons.home_outlined,
            label: l10n.homeCategory,
            selected: _section == HomeSection.productCategory,
            onTap: () => setState(() => _section = HomeSection.productCategory),
          ),
          FrostedBottomMenuItem(
            icon: Icons.inventory_2_outlined,
            label: l10n.homeProducts,
            selected: _section == HomeSection.products,
            onTap: () => setState(() => _section = HomeSection.products),
          ),
          FrostedBottomMenuItem(
            icon: Icons.shopping_bag_outlined,
            label: l10n.homeCart,
            selected: _section == HomeSection.cart,
            onTap: () => setState(() => _section = HomeSection.cart),
          ),
          FrostedBottomMenuItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: _section == HomeSection.profile,
            onTap: () => setState(() => _section = HomeSection.profile),
            onPointerDown: (_) => _beginProfileSwitchSiteHold(),
            onPointerUp: (_) => _cancelProfileSwitchSiteHold(),
            onPointerCancel: (_) => _cancelProfileSwitchSiteHold(),
          ),
        ],
      ),
    );
  }
}
