import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';

/// ?????????????
class CartRequests {
  CartRequests._();

  // static const String listBySitePath = '/store/cart/listsBySite';
  static const String listBySitePath = '/store/cart/listsByDept';
  static const String numPath = '/store/cart/num';
  static const String selectedPath = '/store/cart/selected';
  static const String changePath = '/store/cart/change';
  static const String createPath = '/store/cart/create';
  static const String changeSpecPath = '/store/cart/changeSpec';
  static const String createBySitesPath = '/store/order/createBySites';
  static const String deletePath = '/store/cart/del';
  static const String clearPath = '/store/cart/clear';
  static const String remarkPath = '/store/cart/remark';
  static const String quotationConfigPath = '/store/quotationConfig';
  static const String exportQuotationPath = '/store/cart/exportQuotation';

  /// ????????? SM??????
  static const String setSmPath = '/store/cart/setSm';
}

/// ??????????????
///
/// [client]?????? [protectedDioClient]?
Future<Response<dynamic>> requestCartNum({DioClient? client}) {
  return (client ?? protectedDioClient).get(
    CartRequests.numPath,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// ????????????????
///
/// [bypassMemoryCache]?? `true` ????????????????
/// [client]?????? [protectedDioClient]?
Future<Response<dynamic>> requestCartListBySite({
  DioClient? client,
  int? smStatus = 0,
}) {
  return (client ?? protectedDioClient).get(
    CartRequests.listBySitePath,
    queryParameters: <String, dynamic>{
      'sm_status': smStatus,
    },
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// ????????????????
///
/// [ids]?? id ??????????????
/// [selected]?`1` ???`0` ???
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

/// ??????????????
///
/// [id]????? id?[productNum]??????
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

/// ????????????
///
/// [ids]????? id ???
Future<Response<dynamic>> requestCartDelete({
  required List<int> ids,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.deletePath,
    data: <String, dynamic>{'ids': ids},
  );
}

/// ?????????????
///
/// [companyIds]???????? id?[cart]?????????????
Future<Response<dynamic>> requestCreateOrderBySites({
  required List<int> companyIds,
  required List<Map<String, dynamic>> cart,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.createBySitesPath,
    data: <String, dynamic>{'company_ids': companyIds, 'cart': cart},
  );
}

/// ??????????????
///
/// [id]????? id?[remark]??????
Future<Response<dynamic>> requestCartRemark({
  required int id,
  required String remark,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.remarkPath,
    data: <String, dynamic>{'id': id, 'remark': remark},
  );
}

/// ??????????????
///
/// [companyId]??? id?
Future<Response<dynamic>> requestCartClear({
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.clearPath,
    data: <String, dynamic>{'company_id': companyId},
  );
}

/// ???????????????
Future<Response<dynamic>> requestQuotationConfig({DioClient? client}) {
  return (client ?? protectedDioClient).get(
    CartRequests.quotationConfigPath,
    simpleResponse: false,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// ???????????
Future<Response<dynamic>> requestExportQuotation({
  required Map<String, dynamic> formData,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.exportQuotationPath,
    data: formData,
    simpleResponse: false,
    options: Options(
      responseType: ResponseType.bytes,
      extra: <String, dynamic>{'noCache': true},
    ),
  );
}

/// ???????????
Future<Response<dynamic>> requestExportQuotationPreview({
  required Map<String, dynamic> formData,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.exportQuotationPath,
    data: <String, dynamic>{...formData, 'response_type': 1},
    simpleResponse: false,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// ????????
///
/// [productId] / [subIndex] / [productNum] / [space] / [subName]????
/// ?????????
Future<Response<dynamic>> requestCartCreate({
  required int productId,
  required String subIndex,
  required int productNum,
  required String space,
  required String subName,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.createPath,
    simpleResponse: false,
    data: <String, dynamic>{
      'product_id': productId,
      'sub_index': subIndex,
      'product_num': productNum,
      'space': space,
      'sub_name': subName,
      /// 1?????????????????
      'sm_check': 1,
      'all_shop': 1,
    },
  );
}

/// ?????????????
///
/// [id]?????? id???????????
Future<Response<dynamic>> requestCartChangeSpec({
  required int id,
  required int productId,
  required String subIndex,
  required String space,
  required String subName,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.changeSpecPath,
    data: <String, dynamic>{
      'id': id,
      'product_id': productId,
      'sub_index': subIndex,
      'space': space,
      'sub_name': subName,
    },
  );
}

/// ?????????? SM??????
///
/// [data]?`[{ shop_department_id, sm_id }, ...]`?????? `id` ???
Future<Response<dynamic>> requestCartSetSm({
  required List<Map<String, dynamic>> data,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.setSmPath,
    simpleResponse: false,
    data: <String, dynamic>{'data': data},
  );
}
