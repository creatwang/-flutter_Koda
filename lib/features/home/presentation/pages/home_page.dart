import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/cart/presentation/pages/cart_page.dart';
import 'package:groe_app_pad/features/cart/controllers/cart_providers.dart';
import 'package:groe_app_pad/features/profile/presentation/pages/profile_page.dart';
import 'package:groe_app_pad/features/product/presentation/pages/product_list_page.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/adaptive_scaffold.dart';
import 'package:groe_app_pad/shared/widgets/frosted_bottom_menu.dart';
import 'package:groe_app_pad/shared/widgets/header_menu_button.dart';

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

  @override
  void initState() {
    super.initState();
    _section = _tabToSection(widget.initialTab);
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
        ? ref.watch(cartBadgeCountProvider)
        : 0;

    final Widget body = switch (_section) {
      HomeSection.products => const ProductListPage(),
      // HomeSection.products => const ProductDetailPage(productId: 117276),
      HomeSection.cart => const CartPage(),
      HomeSection.productCategory => const ProductCategoryPage(),
      HomeSection.profile => const ProfilePage(),
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
        HeaderMenuButton(
          label: 'Profile',
          icon: Icons.person_outline,
          selected: _section == HomeSection.profile,
          onTap: () => setState(() => _section = HomeSection.profile),
        ),
        IconButton(
          tooltip: l10n.commonLogout,
          onPressed: () async {
            await ref.read(sessionControllerProvider.notifier).signOut();
            if (context.mounted) context.go(AppRoutes.login);
          },
          icon: const Icon(Icons.logout),
        ),
      ],
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              tooltip: 'Secure Storage Debug',
              onPressed: () => context.push(AppRoutes.secureStorageDebug),
              child: const Icon(Icons.bug_report_outlined),
            )
          : null,
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
          ),
        ],
      ),
    );
  }
}
