import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/cart/api/cart_requests.dart';
import 'package:groe_app_pad/features/cart/models/cart_list_dto.dart';

/// 购物车网络结果解析与 [AppException] 映射（调用 `cart_requests`）。
Future<ApiResult<List<CartListDto>>> fetchCartListBySiteService({
  bool bypassMemoryCache = false,
}) async {
  try {
    final response = await requestCartListBySite(
      bypassMemoryCache: bypassMemoryCache,
    );
    final data = response.data;
    if (data is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid cart list response format',
      );
    }
    final cartList = data
        .whereType<Map>()
        .map((e) => CartListDto.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    return ApiSuccess(cartList);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch cart list failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 批量更新购物车行选中态。
///
/// [ids]：行 id；[selected]：目标选中状态。
Future<ApiResult<void>> updateCartSelectedService({
  required List<int> ids,
  required bool selected,
}) async {
  try {
    await requestCartSelected(ids: ids, selected: selected ? 1 : 0);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Update cart selected failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 修改单行购买数量。
///
/// [id]：购物车行 id；[productNum]：新数量。
Future<ApiResult<void>> changeCartQuantityService({
  required int id,
  required int productNum,
}) async {
  try {
    await requestCartChangeQuantity(id: id, productNum: productNum);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Change cart quantity failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 删除购物车行。
///
/// [ids]：待删除行 id 列表。
Future<ApiResult<void>> removeCartItemsService({required List<int> ids}) async {
  try {
    await requestCartDelete(ids: ids);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Delete cart item failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 多站点合并下单。
///
/// [companyIds]：站点集合；[cart]：接口要求的购物车负载。
Future<ApiResult<void>> createOrderBySitesService({
  required List<int> companyIds,
  required List<Map<String, dynamic>> cart,
}) async {
  try {
    await requestCreateOrderBySites(
      companyIds: companyIds,
      cart: cart,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Create order failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 按站点清空购物车。
///
/// [companyId]：站点 id。
Future<ApiResult<void>> clearCartBySiteService({required int companyId}) async {
  try {
    await requestCartClear(companyId: companyId);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Clear cart failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 加购。
///
/// 字段与后端 `create` 接口一致。
Future<ApiResult<void>> createCartItemService({
  required int productId,
  required String subIndex,
  required int productNum,
  required String space,
  required String subName,
}) async {
  try {
    await requestCartCreate(
      productId: productId,
      subIndex: subIndex,
      productNum: productNum,
      space: space,
      subName: subName,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Add to cart failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 购物车行改规格。
///
/// [id]：原行 id；其余同加购语义。
Future<ApiResult<void>> changeCartItemSpecService({
  required int id,
  required int productId,
  required String subIndex,
  required String space,
  required String subName,
}) async {
  try {
    await requestCartChangeSpec(
      id: id,
      productId: productId,
      subIndex: subIndex,
      space: space,
      subName: subName,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Change cart spec failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
