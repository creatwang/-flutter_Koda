import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';
import 'package:george_pick_mate/features/product/api/product_requests.dart';
import 'package:george_pick_mate/features/product/models/product_category_tree_dto.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/models/product_dto.dart';
import 'package:george_pick_mate/features/product/models/product_fav_dto.dart';
import 'package:george_pick_mate/features/product/models/product_item.dart';

class FavoriteProductsPageResult {
  const FavoriteProductsPageResult({
    required this.items,
    required this.total,
  });

  final List<ProductItem> items;
  final int total;
}

Future<ApiResult<List<ProductItem>>> fetchProductsPageService({
  required int page,
  required int pageSize,
  int shopCateGoryId = 0,
  String? sort,
  int orderBy = 0,
  bool onlyShowroomSample = false,
  String? keyword,
  List<String>? uniqids,
  String? forwardedHost,
}) async {
  try {
    final response = await requestProductsPage(
      page: page,
      pageSize: pageSize,
      shopCateGoryId: shopCateGoryId,
      sort: sort,
      orderBy: orderBy,
      onlyShowroomSample: onlyShowroomSample,
      keyword: keyword,
      uniqids: uniqids,
      forwardedHost: forwardedHost,
    );
    return _parseProductsPageResponse(response);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchProductsFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

ApiResult<List<ProductItem>> _parseProductsPageResponse(
  Response<dynamic> response,
) {
  try {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidProductResponseFormat,
      );
    }
    final list = data['items'];
    if (list is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidProductsListFormat,
      );
    }
    final dtos = list
        .whereType<Map>()
        .map((e) => ProductDto.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    return ApiSuccess(dtos.map((e) => e.toModel()).toList(growable: false));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchProductsFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<FavoriteProductsPageResult>> fetchFavorProductsPageService({
  required int page,
  required int pageSize,
}) async {
  try {
    final response = await requestFavorPageList(
      page: page,
      pageSize: pageSize,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidFavoritesResponseFormat,
      );
    }
    final list = data['items'];
    if (list is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidFavoritesListFormat,
      );
    }
    final dtos = list
        .whereType<Map>()
        .map((e) => ProductFavDto.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    final total = _readInt(data['total'], fallback: dtos.length);
    return ApiSuccess(
      FavoriteProductsPageResult(
        items: dtos.map((e) => e.toModel()).toList(growable: false),
        total: total,
      ),
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchFavoritesFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

int _readInt(dynamic raw, {required int fallback}) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? fallback;
  return fallback;
}

Future<ApiResult<List<ProductCategoryTreeDto>>> fetchCategoryTreeService() async {
  try {
    final response = await requestCategoryTree();
    final data = response.data;

    List<dynamic>? rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List) {
        rawList = items;
      }
    }

    if (rawList == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidCategoryTreeResponseFormat,
      );
    }

    final categories = rawList
        .whereType<Map>()
        .map(
          (e) => ProductCategoryTreeDto.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList(growable: false);
    return ApiSuccess(categories);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchCategoryTreeFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<ProductItem>> fetchProductByIdService(int id) async {
  try {
    final response = await requestProductById(id);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidProductDetailResponseFormat,
      );
    }
    return ApiSuccess(ProductDto.fromJson(data).toModel());
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchProductDetailFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<ProductDetailDto>> fetchProductDetailService(
  int id, {
  String? forwardedHost,
}) async {
  try {
    final response = await requestProductDetail(
      id: id,
      forwardedHost: forwardedHost,
    );
    final data = response.data;
    Map<String, dynamic>? payload;
    if (data is Map<String, dynamic>) {
      final result = data['result'];
      if (result is Map<String, dynamic>) {
        payload = result;
      } else {
        payload = data;
      }
    }
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidProductDetailResponseFormat,
      );
    }
    return ApiSuccess(ProductDetailDto.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchProductDetailFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<void>> createFavorService({required int productId}) async {
  try {
    await createFavorRequest(productId: productId.toString());
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorCreateFavoriteFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<void>> deleteFavorService({required int productId}) async {
  try {
    await deleteFavorRequest(productId: productId.toString());
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorDeleteFavoriteFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
