import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/product/api/product_requests.dart';
import 'package:george_pick_mate/features/product/models/product_category_tree_dto.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/models/product_dto.dart';
import 'package:george_pick_mate/features/product/models/product_fav_dto.dart';
import 'package:george_pick_mate/features/product/models/product_item.dart';

/// 商品列表、收藏、分类、详情等业务封装（依赖当前站点 `companyId`）。
class FavoriteProductsPageResult {
  /// [items]：本页商品；[total]：服务端总数（用于分页）。
  const FavoriteProductsPageResult({
    required this.items,
    required this.total,
  });

  final List<ProductItem> items;
  final int total;
}

/// 商品分页列表（当前站点）。
///
/// [page] / [pageSize]：分页；[shopCateGoryId]：店铺分类；
/// [sort] / [orderBy]：排序参数。
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

/// 收藏商品分页。
///
/// [page] / [pageSize]：分页（站点取自本地 `companyId`）。
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

/// 当前站点下的商品分类树。
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

/// 列表接口形态的单商品（REST 子路径），映射为 [ProductItem]。
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

/// 商品详情页数据（开放详情接口 + `result` 解包兼容）。
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

/// 添加收藏（当前站点）。
///
/// [productId]：商品 id。
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

/// 取消收藏（当前站点）。
///
/// [productId]：商品 id。
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
