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
}

Future<Response<dynamic>> requestProductsPage({
  required int page,
  required int pageSize,
  required String? companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.productsPath,
    queryParameters: {
      'page_size': pageSize,
      'company_id': companyId,
      'page': (page - 1) * pageSize,
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
  return (client ?? protectedDioClient).get(
    ProductRequests.createFavorPath,
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
  return (client ?? protectedDioClient).get(
    ProductRequests.deleteFavorPath,
    queryParameters: {
      'product_id': productId,
      'company_id': companyId,
    },
  );
}
