// 购物车：按站点分组列表与加购、改规格、下单等操作。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/auth/models/session.dart';
import 'package:george_pick_mate/features/cart/models/cart_list_dto.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_config_dto.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_export_result_dto.dart';
import 'package:george_pick_mate/features/cart/services/cart_persistence_services.dart';
import 'package:george_pick_mate/features/cart/services/cart_services.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';

/// 购物车主状态（监听会话以在站点切换时自动刷新）。
final cartControllerProvider =
    AsyncNotifierProvider<CartController, List<CartListDto>>(
      CartController.new,
    );

/// 预订单列表与操作（`sm_status=1`），与 [CartController] 共用接口实现。
///
/// `autoDispose`：离开预订单页后释放，再次进入会重新执行 [build] 拉列表。
final preOrderCartControllerProvider =
    AsyncNotifierProvider.autoDispose(
      PreOrderCartController.new,
    );

bool _isAuthenticatedBySession(Session? session) {
  return session?.isAuthenticated == true;
}

/// 角标与购物车页总件数：由当前购物车列表汇总，**不**请求 `/store/cart/num`。
final cartListBadgeCountProvider = Provider<int>((ref) {
  return _badgeSumFromCartList(ref.watch(cartControllerProvider).asData?.value);
});

/// 个人中心侧栏 CART NUM：仅在打开 Profile 时请求 `/store/cart/num` 写入快照；
/// 离开 Profile 或未拉取成功前用 [cartListBadgeCountProvider]。
final profileCartServerNumProvider =
    NotifierProvider.autoDispose<ProfileCartServerNumNotifier, int?>(
      ProfileCartServerNumNotifier.new,
    );

/// Profile 打开后被监听时自动拉取 `/store/cart/num`，离开后自动释放。
class ProfileCartServerNumNotifier extends Notifier<int?> {
  @override
  int? build() {
    ref.listen(sessionControllerProvider, (_, next) {
      if (next.asData?.value.isAuthenticated != true) {
        state = null;
      }
    });
    unawaited(fetchOnProfileOpen());
    return null;
  }

  Future<void> fetchOnProfileOpen() async {
    final session = ref.read(sessionControllerProvider).asData?.value;
    if (!ref.mounted) return;
    if (!_isAuthenticatedBySession(session)) {
      state = null;
      return;
    }
    final result = await fetchCartTotalNumService();
    if (!ref.mounted) return;
    result.when(success: (n) => state = n, failure: (_) => state = null);
  }

  void clearSnapshot() => state = null;
}

/// 当前选中行数量之和。
final cartSelectedCountProvider = Provider<int>((ref) {
  final cartData = ref.watch(cartControllerProvider).asData?.value;
  if (cartData == null) return 0;
  return _allProducts(cartData)
      .where((item) => item.isSelected)
      .fold<int>(0, (sum, item) => sum + item.productNum);
});

/// 预订单列表中选中行的件数之和（口径同 [cartSelectedCountProvider]）。
final preOrderSelectedCountProvider = Provider<int>((ref) {
  final cartData = ref.watch(preOrderCartControllerProvider).asData?.value;
  if (cartData == null) return 0;
  return _allProducts(cartData)
      .where((item) => item.isSelected)
      .fold<int>(0, (sum, item) => sum + item.productNum);
});

/// 选中行金额小计（单价 × 数量）。
final cartSelectedAmountProvider = Provider<double>((ref) {
  final cartData = ref.watch(cartControllerProvider).asData?.value;
  if (cartData == null) return 0;
  return _allProducts(cartData)
      .where((item) => item.isSelected)
      .fold<double>(0, (sum, item) => sum + item.price * item.productNum);
});

/// 购物车业务入口：与 [cart_services] 交互并维护乐观更新。
class CartController extends AsyncNotifier<List<CartListDto>> {
  /// 列表拉取参数 `sm_status`：`0` 购物车，`1` 预订单。
  int get listSmStatus => 0;

  bool get _persistCartListLocally => listSmStatus == 0;

  @override
  FutureOr<List<CartListDto>> build() async {
    // 仅依赖 [sessionControllerProvider]：会话/站点变化会触发本 build
    // 重新拉取购物车，无需再叠一层 [ref.listen]（避免双请求与交叉逻辑）。
    final session = ref.watch(sessionControllerProvider).asData?.value;
    if (!_isAuthenticatedBySession(session)) {
      return const <CartListDto>[];
    }

    final cached = _persistCartListLocally
        ? await readCartListFromLocal()
        : const <CartListDto>[];
    final result = await fetchCartListBySiteService(smStatus: 0);
    if (result is ApiSuccess<List<CartListDto>>) {
      final latest = result.data;
      if (_persistCartListLocally) {
        unawaited(saveCartListToLocal(items: latest));
      }
      return latest;
    }
    if (cached.isNotEmpty) return cached;
    throw (result as ApiFailure<List<CartListDto>>).exception;
  }

  Future<void> refresh() async {
    if (!_isAuthenticated()) {
      state = const AsyncData(<CartListDto>[]);
      return;
    }
    final result = await fetchCartListBySiteService(
      smStatus: 0,
    );
    result.when(
      success: (data) {
        state = AsyncData(data);
        if (_persistCartListLocally) {
          unawaited(saveCartListToLocal(items: data));
        }
      },
      failure: (_) {},
    );
  }

  Future<bool> createCartItem({
    required int productId,
    required String subIndex,
    required int productNum,
    required String space,
    required String subName,
  }) async {
    if (!_isAuthenticated()) {
      Future<void>.microtask(
        () => showGlobalErrorMessage('Please sign in first.'),
      );
      return false;
    }
    if (productNum < 1) {
      Future<void>.microtask(
        () => showGlobalErrorMessage('Invalid product quantity.'),
      );
      return false;
    }
    final result = await createCartItemService(
      productId: productId,
      subIndex: subIndex,
      productNum: productNum,
      space: space,
      subName: subName,
    );
    return result.when(
      success: (_) {
        unawaited(refresh());
        return true;
      },
      failure: (exception) {
        Future<void>.microtask(
          () => showGlobalErrorMessage(exception.message),
        );
        return false;
      },
    );
  }

  Future<bool> changeCartItemSpec({
    required int cartItemId,
    required int productId,
    required String subIndex,
    required String space,
    required String subName,
  }) async {
    if (!_isAuthenticated()) return false;
    final result = await changeCartItemSpecService(
      id: cartItemId,
      productId: productId,
      subIndex: subIndex,
      space: space,
      subName: subName,
    );
    return result.when(
      success: (_) {
        unawaited(refresh());
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> toggleProductSelected({
    required int cartId,
    required bool selected,
  }) async {
    final ids = <int>[cartId];
    return _applySelection(ids: ids, selected: selected);
  }

  Future<bool> toggleSiteSelected({
    required int companyId,
    required bool selected,
  }) async {
    final current = state.asData?.value ?? const <CartListDto>[];
    final site = _findSiteByCompanyId(current, companyId);
    if (site == null) return false;
    final ids = _productIdsInSite(site);
    if (ids.isEmpty) return false;
    return _applySelection(ids: ids, selected: selected);
  }

  Future<bool> changeProductQuantity({
    required int cartId,
    required int productNum,
  }) async {
    if (!_isAuthenticated()) return false;
    if (productNum < 1) return false;

    final previous = state.asData?.value ?? const <CartListDto>[];
    final next = _mapProducts(
      previous,
      (item) =>
          item.id == cartId ? item.copyWith(productNum: productNum) : item,
    );
    state = AsyncData(next);

    final result = await changeCartQuantityService(
      id: cartId,
      productNum: productNum,
    );
    return result.when(
      success: (_) {
        if (_persistCartListLocally) {
          unawaited(saveCartListToLocal(items: next));
        }
        return true;
      },
      failure: (_) {
        state = AsyncData(previous);
        return false;
      },
    );
  }

  Future<bool> removeCartItem(int cartId) async {
    if (!_isAuthenticated()) return false;
    final result = await removeCartItemsService(ids: <int>[cartId]);
    return result.when(
      success: (_) async {
        await refresh();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> removeSelectedItems() async {
    if (!_isAuthenticated()) return false;
    final current = state.asData?.value ?? const <CartListDto>[];
    final selectedIds = _allProducts(current)
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toSet()
        .toList(growable: false);
    if (selectedIds.isEmpty) return false;
    final result = await removeCartItemsService(ids: selectedIds);
    return result.when(
      success: (_) async {
        await refresh();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> updateProductRemark({
    required int cartId,
    required String remark,
  }) async {
    if (!_isAuthenticated()) return false;
    final current = state.asData?.value ?? const <CartListDto>[];
    final next = _mapProducts(
      current,
      (item) => item.id == cartId ? item.copyWith(remark: remark) : item,
    );
    state = AsyncData(next);
    if (_persistCartListLocally) {
      unawaited(saveCartListToLocal(items: next));
    }
    return true;
  }

  Future<bool> clearSiteCart(int companyId, {bool shouldRefresh = true}) async {
    if (!_isAuthenticated()) return false;
    final result = await clearCartBySiteService(companyId: companyId);
    return result.when(
      success: (_) async {
        if (shouldRefresh) await refresh();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> clearAllSitesCart() async {
    final sites = state.asData?.value ?? const <CartListDto>[];
    final siteIds = sites
        .expand((group) => group.items)
        .map((site) => site.companyId)
        .toSet()
        .toList(growable: false);
    if (siteIds.isEmpty) return false;
    var allSuccess = true;
    for (final siteId in siteIds) {
      final ok = await clearSiteCart(siteId, shouldRefresh: false);
      if (!ok) allSuccess = false;
    }
    await refresh();
    return allSuccess;
  }

  CartCreateOrderBySitesPayload buildCreateBySitesPayload() {
    final data = state.asData?.value ?? const <CartListDto>[];
    final selectedItems = _allProducts(data)
        .where((item) => item.isSelected && item.productNum > 0)
        .toList(growable: false);
    final selectedIds = selectedItems.map((item) => item.id).toSet();
    final companyIds = data
        .expand((group) => group.items)
        .where(
          (site) => site.cart.items.any(
            (space) => space.list.any((item) => selectedIds.contains(item.id)),
          ),
        )
        .map((site) => site.companyId)
        .toSet()
        .toList(growable: false);
    final cart = selectedItems
        .map((item) => <String, dynamic>{'id': item.id, 'remark': item.remark})
        .toList(growable: false);
    return CartCreateOrderBySitesPayload(companyIds: companyIds, cart: cart);
  }

  Future<bool> createOrderBySites({
    required List<int> companyIds,
    required List<Map<String, dynamic>> cart,
  }) async {
    if (!_isAuthenticated()) return false;
    if (companyIds.isEmpty || cart.isEmpty) return false;
    final result = await createOrderBySitesService(
      companyIds: companyIds,
      cart: cart,
    );
    return result.when(success: (_) => true, failure: (_) => false);
  }

  Future<ApiResult<CartQuotationConfigDto>> fetchQuotationConfig() async {
    if (!_isAuthenticated()) {
      return ApiFailure(AppException('Please sign in first.'));
    }
    return fetchQuotationConfigService();
  }

  Future<ApiResult<CartQuotationExportResultDto>> exportQuotation({
    required Map<String, dynamic> formData,
  }) async {
    if (!_isAuthenticated()) {
      return ApiFailure(AppException('Please sign in first.'));
    }
    return exportQuotationService(formData: formData);
  }

  Future<ApiResult<String>> previewQuotation({
    required Map<String, dynamic> formData,
  }) async {
    if (!_isAuthenticated()) {
      return ApiFailure(AppException('Please sign in first.'));
    }
    return previewQuotationService(formData: formData);
  }

  Future<bool> _applySelection({
    required List<int> ids,
    required bool selected,
  }) async {
    if (!_isAuthenticated() || ids.isEmpty) return false;
    final previous = state.asData?.value ?? const <CartListDto>[];
    final next = _mapProducts(
      previous,
      (item) => ids.contains(item.id)
          ? item.copyWith(selected: selected ? 1 : 0)
          : item,
    );
    state = AsyncData(next);

    final result = await updateCartSelectedService(
      ids: ids,
      selected: selected,
    );
    return result.when(
      success: (_) {
        if (_persistCartListLocally) {
          unawaited(saveCartListToLocal(items: next));
        }
        return true;
      },
      failure: (_) {
        state = AsyncData(previous);
        return false;
      },
    );
  }

  bool _isAuthenticated() {
    final session = ref.read(sessionControllerProvider).asData?.value;
    return _isAuthenticatedBySession(session);
  }
}

class PreOrderCartController extends CartController {
  @override
  int get listSmStatus => 1;
}

int _badgeSumFromCartList(List<CartListDto>? cartData) {
  if (cartData == null) return 0;
  return _allProducts(
    cartData,
  ).fold<int>(0, (sum, item) => sum + item.productNum);
}

List<CartProductDto> _allProducts(List<CartListDto> source) {
  return source
      .expand((group) => group.items)
      .expand((site) => site.cart.items)
      .expand((space) => space.list)
      .toList(growable: false);
}

CartSiteDto? _findSiteByCompanyId(List<CartListDto> source, int companyId) {
  for (final group in source) {
    for (final site in group.items) {
      if (site.companyId == companyId) return site;
    }
  }
  return null;
}

List<int> _productIdsInSite(CartSiteDto site) {
  return site.cart.items
      .expand((space) => space.list)
      .map((item) => item.id)
      .toList(growable: false);
}

List<CartListDto> _mapProducts(
  List<CartListDto> source,
  CartProductDto Function(CartProductDto item) mapper,
) {
  return source
      .map(
        (group) => CartListDto(
          totalNum: group.totalNum,
          totalAmount: group.totalAmount,
          id: group.id,
          name: group.name,
          items: group.items
              .map(
                (site) => site.copyWith(
                  cart: site.cart.copyWith(
                    items: site.cart.items
                        .map(
                          (space) => space.copyWith(
                            list: space.list
                                .map(mapper)
                                .toList(growable: false),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      )
      .toList(growable: false);
}

class CartCreateOrderBySitesPayload {
  const CartCreateOrderBySitesPayload({
    required this.companyIds,
    required this.cart,
  });

  final List<int> companyIds;
  final List<Map<String, dynamic>> cart;
}
