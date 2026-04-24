import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/controllers/main_user_providers.dart';
import 'package:george_pick_mate/features/profile/controllers/profile_page_controller.dart';
import 'package:george_pick_mate/features/profile/controllers/profile_providers.dart';
import 'package:george_pick_mate/features/profile/controllers/customer_account_providers.dart';
import 'package:george_pick_mate/features/profile/models/profile_content_section.dart';
import 'package:george_pick_mate/features/profile/models/profile_section_meta.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/profile_content_area_widget.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/profile_order_center_section_widget.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/profile_sidebar_widget.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/store_customer_common_password_bottom_sheet.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/store_customer_form_bottom_sheet.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/switch_site_bottom_sheet.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/shared/widgets/home_main_content_slot_widget.dart';

class HomeStartPage extends ConsumerStatefulWidget {
  const HomeStartPage({
    super.key,
    this.showSwitchSiteEntry = false,
  });

  /// 由首页「Profile」入口长按 10s 切换；为 `true` 时在设置中展示切换站点按钮。
  final bool showSwitchSiteEntry;

  @override
  ConsumerState<HomeStartPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<HomeStartPage> {


  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/home_bgc.webp',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: Color(0xFFE8ECEF)),
        ),
        HomeMainContentSlot(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [Text('data')],
          ),
        ),
      ],
    );
  }
}
