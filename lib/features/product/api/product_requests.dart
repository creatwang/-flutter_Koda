import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';

import '../../../core/platform_services/network_clients.dart';

class ProductRequests {
  static const String productsPath = '/store/product/lists';
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
