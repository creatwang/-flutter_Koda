import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/product/api/product_requests.dart';
import 'package:groe_app_pad/features/product/models/product_category_tree_dto.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/models/product_dto.dart';
import 'package:groe_app_pad/features/product/models/product_fav_dto.dart';

import '../../../core/platform_services/network_clients.dart';

class FavoriteProductsPageResult {
  const FavoriteProductsPageResult({required this.items, required this.total});

  final List<ProductItem> items;
  final int total;
}

Future<ApiResult<List<ProductItem>>> fetchProductsPageService({
  required int page,
  required int pageSize,
  int shopCateGoryId = 0,
  String? sort,
  int orderBy = 0,
}) async {
  final companyId = await secureStorageService.getCompanyId();
  if (companyId == null) {
    return ApiFailure(const AppException('Missing company id'));
  }
  try {
    final response = await requestProductsPage(
      page: page,
      pageSize: pageSize,
      companyId: companyId,
      shopCateGoryId: shopCateGoryId,
      sort: sort,
      orderBy: orderBy,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid product response format',
      );
    }
    final list = data['items'];
    if (list is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid products list format',
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
        e.message ?? 'Fetch products failed',
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
  final companyId = await secureStorageService.getCompanyId();
  if (companyId == null) {
    return ApiFailure(const AppException('Missing company id'));
  }
  try {
    final response = await requestFavorPageList(
      page: page,
      pageSize: pageSize,
      companyId: companyId,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid favorites response format',
      );
    }
    final list = data['items'];
    if (list is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid favorites list format',
      );
    }
    final dtos = list
        .whereType<Map>()
        .map((e) => ProductFavDto.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    return ApiSuccess(
      FavoriteProductsPageResult(
        items: dtos.map((e) => e.toModel()).toList(growable: false),
        total: _parseTotalCount(data, fallback: dtos.length),
      ),
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch favorites failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

int _parseTotalCount(Map<String, dynamic> data, {required int fallback}) {
  final raw = data['total'] ?? data['count'] ?? data['total_count'];
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? fallback;
  return fallback;
}

Future<ApiResult<List<ProductCategoryTreeDto>>>
fetchCategoryTreeService() async {
  final companyId = await secureStorageService.getCompanyId();
  if (companyId == null) {
    return ApiFailure(const AppException('Missing company id'));
  }
  try {
    final response = await requestCategoryTree(companyId: companyId);
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
        error: 'Invalid category tree response format',
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
        e.message ?? 'Fetch category tree failed',
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
        error: 'Invalid product detail response format',
      );
    }
    return ApiSuccess(ProductDto.fromJson(data).toModel());
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch product detail failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<ProductDetailDto>> fetchProductDetailService(int id) async {
  try {
    final response = await requestProductDetail(id: id);
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
        error: 'Invalid product detail response format',
      );
    }
    return ApiSuccess(ProductDetailDto.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch product detail failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<void>> createFavorService({required int productId}) async {
  final companyId = await secureStorageService.getCompanyId();
  if (companyId == null) {
    return ApiFailure(const AppException('Missing company id'));
  }
  try {
    await createFavorRequest(
      productId: productId.toString(),
      companyId: companyId,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Create favorite failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<void>> deleteFavorService({required int productId}) async {
  final companyId = await secureStorageService.getCompanyId();
  if (companyId == null) {
    return ApiFailure(const AppException('Missing company id'));
  }
  try {
    await deleteFavorRequest(
      productId: productId.toString(),
      companyId: companyId,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Delete favorite failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
