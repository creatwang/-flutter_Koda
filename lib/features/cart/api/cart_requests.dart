import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

class CartRequests {
  static const String listBySitePath = '/store/cart/listsBySite';
  static const String selectedPath = '/store/cart/selected';
  static const String changePath = '/store/cart/change';
  static const String createBySitesPath = '/store/order/createBySites';
  static const String deletePath = '/store/cart/del';
  static const String clearPath = '/store/cart/clear';
}

Future<Response<dynamic>> requestCartListBySite({DioClient? client}) {
  return (client ?? protectedDioClient).get(CartRequests.listBySitePath);
}

Future<Response<dynamic>> requestCartSelected({
  required List<int> ids,
  required int selected,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.selectedPath,
    data: <String, dynamic>{
      'ids': ids.length == 1 ? ids.first : ids,
      'selected': selected,
    },
  );
}

Future<Response<dynamic>> requestCartChangeQuantity({
  required int id,
  required int productNum,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.changePath,
    data: <String, dynamic>{'id': id, 'product_num': productNum},
  );
}

Future<Response<dynamic>> requestCartDelete({
  required List<int> ids,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.deletePath,
    data: <String, dynamic>{'ids': ids},
  );
}

Future<Response<dynamic>> requestCreateOrderBySites({
  required List<int> companyIds,
  required List<Map<String, dynamic>> cart,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.createBySitesPath,
    data: <String, dynamic>{
      'company_ids': companyIds,
      'cart': cart,
    },
  );
}

Future<Response<dynamic>> requestCartClear({
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.clearPath,
    data: <String, dynamic>{'company_id': companyId},
  );
}
