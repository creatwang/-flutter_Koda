import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';

/// 购物车与下单相关接口路径。
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
  static const String quotationConfigPath = '/store/quotationConfig';
  static const String exportQuotationPath = '/store/cart/exportQuotation';
}

/// 购物车商品总件数（需鉴权）。
///
/// [client]：可选，默认 [protectedDioClient]。
Future<Response<dynamic>> requestCartNum({DioClient? client}) {
  return (client ?? protectedDioClient).get(
    CartRequests.numPath,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// 按站点拉取购物车列表（需鉴权）。
///
/// [bypassMemoryCache]：为 `true` 时在请求上附加跳过内存缓存标记。
/// [client]：可选，默认 [protectedDioClient]。
Future<Response<dynamic>> requestCartListBySite({
  DioClient? client,
  bool bypassMemoryCache = false,
}) {
  return (client ?? protectedDioClient).get(
    CartRequests.listBySitePath,
    options: bypassMemoryCache
        ? Options(extra: <String, dynamic>{'noCache': true})
        : null,
  );
}

/// 更新购物车行选中状态（需鉴权）。
///
/// [ids]：行 id 列表；单条时请求体会发标量。
/// [selected]：`1` 选中，`0` 取消。
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

/// 修改购物车行数量（需鉴权）。
///
/// [id]：购物车行 id；[productNum]：目标数量。
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

/// 删除购物车行（需鉴权）。
///
/// [ids]：待删除行 id 列表。
Future<Response<dynamic>> requestCartDelete({
  required List<int> ids,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.deletePath,
    data: <String, dynamic>{'ids': ids},
  );
}

/// 多站点合并下单（需鉴权）。
///
/// [companyIds]：参与下单的站点 id；[cart]：接口要求的购物车结构体。
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

/// 清空某站点购物车（需鉴权）。
///
/// [companyId]：站点 id。
Future<Response<dynamic>> requestCartClear({
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.clearPath,
    data: <String, dynamic>{'company_id': companyId},
  );
}

/// 获取报价单导出配置（需鉴权）。
Future<Response<dynamic>> requestQuotationConfig({DioClient? client}) {
  return (client ?? protectedDioClient).get(
    CartRequests.quotationConfigPath,
    simpleResponse: false,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// 导出报价单（需鉴权）。
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

/// 预览报价单（需鉴权）。
Future<Response<dynamic>> requestExportQuotationPreview({
  required Map<String, dynamic> formData,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.exportQuotationPath,
    data: <String, dynamic> {...formData, 'response_type': 1},
    simpleResponse: false,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// 加购（需鉴权）。
///
/// [productId] / [subIndex] / [productNum] / [space] / [subName]：与后端
/// 加购接口字段一致。
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
      /// 1、检测购物车是否存在未预下单的产品
      'sm_check': 1,
    },
  );
}

/// 购物车行改规格（需鉴权）。
///
/// [id]：原购物车行 id；其余字段同加购语义。
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
