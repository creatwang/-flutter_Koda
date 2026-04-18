import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/auth/models/session.dart';
import 'package:groe_app_pad/features/cart/models/cart_list_dto.dart';
import 'package:groe_app_pad/features/cart/services/cart_persistence_services.dart';
import 'package:groe_app_pad/features/cart/services/cart_services.dart';

final cartControllerProvider =
    AsyncNotifierProvider<CartController, List<CartListDto>>(
      CartController.new,
    );

final cartBadgeCountProvider = Provider<int>((ref) {
  final cartData = ref.watch(cartControllerProvider).asData?.value;
  if (cartData == null) return 0;
  return _allProducts(
    cartData,
  ).fold<int>(0, (sum, item) => sum + item.productNum);
});

final cartSelectedCountProvider = Provider<int>((ref) {
  final cartData = ref.watch(cartControllerProvider).asData?.value;
  if (cartData == null) return 0;
  return _allProducts(cartData)
      .where((item) => item.isSelected)
      .fold<int>(0, (sum, item) => sum + item.productNum);
});

final cartSelectedAmountProvider = Provider<double>((ref) {
  final cartData = ref.watch(cartControllerProvider).asData?.value;
  if (cartData == null) return 0;
  return _allProducts(cartData)
      .where((item) => item.isSelected)
      .fold<double>(0, (sum, item) => sum + item.price * item.productNum);
});

class CartController extends AsyncNotifier<List<CartListDto>> {
  @override
  FutureOr<List<CartListDto>> build() async {
    ref.listen<AsyncValue<Session>>(sessionControllerProvider, (
      previous,
      next,
    ) {
      unawaited(_onSessionChanged(previous, next));
    });

    final session = ref.watch(sessionControllerProvider).asData?.value;
    if (!_isAuthenticatedBySession(session)) {
      return const <CartListDto>[];
    }

    final cached = await readCartListFromLocal();
    final result = await fetchCartListBySiteService();
    if (result is ApiSuccess<List<CartListDto>>) {
      final latest = result.data;
      unawaited(saveCartListToLocal(items: latest));
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
    final result = await fetchCartListBySiteService(bypassMemoryCache: true);
    result.when(
      success: (data) {
        state = AsyncData(data);
        unawaited(saveCartListToLocal(items: data));
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
    if (!_isAuthenticated()) return false;
    if (productNum < 1) return false;
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
      failure: (_) => false,
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
        unawaited(saveCartListToLocal(items: next));
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
    unawaited(saveCartListToLocal(items: next));
    return true;
  }

  Future<bool> clearSiteCart(
    int companyId, {
    bool shouldRefresh = true,
  }) async {
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
    return result.when(
      success: (_) => true,
      failure: (_) => false,
    );
  }

  Future<void> _onSessionChanged(
    AsyncValue<Session>? previous,
    AsyncValue<Session> next,
  ) async {
    final previousSession = previous?.asData?.value;
    final nextSession = next.asData?.value;
    if (nextSession == null || nextSession.isAuthenticated != true) {
      state = const AsyncData(<CartListDto>[]);
      unawaited(clearCartListFromLocal());
      return;
    }

    final currentCompanyId = nextSession.companyId;
    final previousCompanyId = previousSession?.companyId;
    if (previousCompanyId == currentCompanyId && state.hasValue) {
      return;
    }
    await refresh();
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
        unawaited(saveCartListToLocal(items: next));
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

  bool _isAuthenticatedBySession(Session? session) {
    return session?.isAuthenticated == true;
  }
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
