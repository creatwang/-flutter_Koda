import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';

/// 门店/站点相关 HTTP 定义（路径、方法、参数形态）。
class StoreCompanyRequests {
  StoreCompanyRequests._();

  /// 开放列表：`GET /store/company`（无需 token）。
  static const String companyListPath = '/store/company';
}

Future<Response<dynamic>> requestStoreCompanyList({
  DioClient? client,
}) {
  return (client ?? publicDioClient).get(
    StoreCompanyRequests.companyListPath,
  );
}
