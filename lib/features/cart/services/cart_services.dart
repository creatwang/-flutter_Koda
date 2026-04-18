import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/cart/api/cart_requests.dart';
import 'package:groe_app_pad/features/cart/models/cart_list_dto.dart';

Future<ApiResult<List<CartListDto>>> fetchCartListBySiteService() async {
  try {
    final response = await requestCartListBySite();
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
