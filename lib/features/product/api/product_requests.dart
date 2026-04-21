import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/network/interceptors/response_data_mode_interceptor.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

/// 商品与收藏相关接口路径。
class ProductRequests {
  ProductRequests._();

  /// `GET` 商品列表
  static const String productsPath = '/store/product/lists';

  /// `POST` 添加收藏
  static const String createFavorPath = '/store/collect/create';

  /// `POST` 删除收藏
  static const String deleteFavorPath = '/store/collect/delete';

  /// `GET` 分类树
  static const String getCategoryTree = '/store/category/tree';

  /// `GET` 商品详情
  static const String getProductDetail = '/store/product/detail';

  /// `GET` 收藏分页
  static const String getFavorPageList = '/store/collect/getPageList';
}

/// 商品详情（开放接口，可按项目需要换 [client]）。
///
/// [id]：商品 id。
Future<Response<dynamic>> requestProductDetail({
  required int id,
  DioClient? client,
}) {
  return (client ?? publicDioClient).get(
    ProductRequests.getProductDetail,
    options: Options(
      extra: <String, dynamic>{
        ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey: true,
      },
    ),
    queryParameters: <String, dynamic>{'id': id},
  );
}

/// 商品分页列表（需鉴权）。
///
/// [page] / [pageSize]：分页；[companyId]：站点；
/// [shopCateGoryId]：店铺分类；[sort] / [orderBy]：排序。
Future<Response<dynamic>> requestProductsPage({
  required int page,
  required int pageSize,
  required int companyId,
  int shopCateGoryId = 0,
  String? sort,
  int orderBy = 0,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.productsPath,
    queryParameters: <String, dynamic>{
      'shop_category_id': shopCateGoryId,
      'order_by': orderBy,
      if (sort != null) 'sort': sort,
      'page_size': pageSize,
      'company_id': companyId,
      'page': page,
    },
  );
}

/// 收藏分页（需鉴权）。
///
/// [page] / [pageSize] / [companyId]：分页与站点。
Future<Response<dynamic>> requestFavorPageList({
  required int page,
  required int pageSize,
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.getFavorPageList,
    queryParameters: <String, dynamic>{
      'page': page,
      'pag_size': pageSize,
      'company_id': companyId,
    },
  );
}

/// 分类树（需鉴权）。
///
/// [companyId]：站点 id，可为 `null` 时由后端默认。
Future<Response<dynamic>> requestCategoryTree({
  required int? companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.getCategoryTree,
    queryParameters: <String, dynamic>{'company_id': companyId},
  );
}

/// 按 id 拉取列表项形态商品（需鉴权，REST 子路径）。
///
/// [id]：商品 id；[client]：可选。
Future<Response<dynamic>> requestProductById(
  int id, {
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    '${ProductRequests.productsPath}/$id',
  );
}

/// 添加收藏（需鉴权）。
///
/// [productId]：商品 id 字符串；[companyId]：站点。
Future<Response<dynamic>> createFavorRequest({
  required String productId,
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    ProductRequests.createFavorPath,
    options: Options(
      extra: <String, dynamic>{
        'noCache': true,
        'noRetry': true,
      },
    ),
    queryParameters: <String, dynamic>{
      'product_id': productId,
      'company_id': companyId,
    },
  );
}

/// 删除收藏（需鉴权）。
///
/// 参数同 [createFavorRequest]。
Future<Response<dynamic>> deleteFavorRequest({
  required String productId,
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    ProductRequests.deleteFavorPath,
    options: Options(
      extra: <String, dynamic>{
        'noCache': true,
        'noRetry': true,
      },
    ),
    queryParameters: <String, dynamic>{
      'product_id': productId,
      'company_id': companyId,
    },
  );
}
