import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/cart/presentation/pages/cart_page.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/order/presentation/pages/order_page.dart';
import 'package:groe_app_pad/features/product/presentation/pages/product_list_page.dart';
import 'package:groe_app_pad/shared/widgets/adaptive_scaffold.dart';
import 'package:groe_app_pad/shared/widgets/header_menu_button.dart';

import '../../../product/presentation/pages/product_category_page.dart';

enum HomeSection { products, cart, orders, productCategory }

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
      'orders' => HomeSection.orders,
      _ => HomeSection.products,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(
      cartControllerProvider.select(
        (value) => value.asData?.value.fold<int>(0, (sum, e) => sum + e.quantity) ?? 0,
      ),
    );

    final Widget body = switch (_section) {
      HomeSection.products => const ProductListPage(),
      HomeSection.cart => const CartPage(),
      HomeSection.orders => const OrderPage(),
      HomeSection.productCategory => const ProductCategoryPage(),
    };

    return AdaptiveScaffold(
      title: 'iPad 商城',
      automaticallyImplyLeading: false,
      actions: [
        HeaderMenuButton(
          label: '产品分类',
          icon: Icons.storefront,
          selected: _section == HomeSection.productCategory,
          onTap: () => setState(() => _section = HomeSection.productCategory),
        ),
        HeaderMenuButton(
          label: '商品',
          icon: Icons.storefront,
          selected: _section == HomeSection.products,
          onTap: () => setState(() => _section = HomeSection.products),
        ),
        HeaderMenuButton(
          label: '购物车($cartCount)',
          icon: Icons.shopping_cart_outlined,
          selected: _section == HomeSection.cart,
          onTap: () => setState(() => _section = HomeSection.cart),
        ),
        HeaderMenuButton(
          label: '订单',
          icon: Icons.receipt_long_outlined,
          selected: _section == HomeSection.orders,
          onTap: () => setState(() => _section = HomeSection.orders),
        ),
        IconButton(
          tooltip: '退出登录',
          onPressed: () async {
            await ref.read(sessionControllerProvider.notifier).signOut();
            if (context.mounted) context.go(AppRoutes.login);
          },
          icon: const Icon(Icons.logout),
        ),
      ],
      body: body,
    );
  }
}
