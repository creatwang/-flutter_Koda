import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';

import '../../../core/platform_services/network_clients.dart';

class ProductRequests {
  /// 产品列表
  static const String productsPath = '/store/product/lists';
  /// 添加收藏
  static const String createFavorPath = '/store/collect/create';
  /// 删除收藏
  static const String deleteFavorPath = '/store/collect/delete';
  /// 获取分类树
  static const String getCategoryTree = '/store/category/tree';
}

Future<Response<dynamic>> requestProductsPage({
  required int page,
  required int pageSize,
  required String companyId,
  int shopCateGoryId = 0,
  String? sort,
  int orderBy = 0,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.productsPath,
    queryParameters: {
      'shopCateGoryId': shopCateGoryId,
      'order_by': orderBy,
      if (sort != null) 'sort': sort,
      'page_size': pageSize,
      'company_id': companyId,
      'page': (page - 1) * pageSize,
    },
  );
}
Future<Response<dynamic>> requestCategoryTree({
  required String? companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.getCategoryTree,
    queryParameters: {
      'company_id': companyId,
    },
  );
}

Future<Response<dynamic>> requestProductById(
  int id, {
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get('${ProductRequests.productsPath}/$id');
}



Future<Response<dynamic>> createFavorRequest({
  required String productId,
  required String companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    ProductRequests.createFavorPath,
    options: Options(
      extra: {
        'noCache': true,
        'noRetry': true,
      },
    ),
    queryParameters: {
      'product_id': productId,
      'company_id': companyId,
    },
  );
}

Future<Response<dynamic>> deleteFavorRequest({
  required String productId,
  required String companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    ProductRequests.deleteFavorPath,
    options: Options(
      extra: {
        'noCache': true,
        'noRetry': true,
      },
    ),
    queryParameters: {
      'product_id': productId,
      'company_id': companyId,
    },
  );
}
