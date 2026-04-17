import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';

import '../../../core/platform_services/network_clients.dart';

class OrderRequests {
  static const String createBySitesPath = '/store/order/createBySites';
}

Future<Response<dynamic>> requestCreateOrderBySites({
  required List<int> companyIds,
  required List<Map<String, dynamic>> cart,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    OrderRequests.createBySitesPath,
    data: <String, dynamic>{'company_ids': companyIds, 'cart': cart},
  );
}
