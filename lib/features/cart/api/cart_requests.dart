import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';

/// 购物车请求路径定义
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

  /// 设置购物车条目与 SM 的关联
  static const String setSmPath = '/store/cart/setSm';
}

/// 获取购物车商品数量
///
/// [client] 默认使用 [protectedDioClient]。
Future<Response<dynamic>> requestCartNum({DioClient? client}) {
  return (client ?? protectedDioClient).get(
    CartRequests.numPath,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// 获取购物车列表（按门店聚合）
///
/// [smStatus] 过滤 SM 状态，默认 `0`。
/// [client] 默认使用 [protectedDioClient]。
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

/// 批量设置购物车商品选中状态
///
/// [ids] 支持单个或多个购物车条目 id。
/// [selected] `1` 表示选中，`0` 表示取消选中。
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

/// 修改购物车商品数量
///
/// [id] 购物车条目 id，[productNum] 目标数量。
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

/// 删除购物车商品
///
/// [ids] 要删除的购物车条目 id 列表。
Future<Response<dynamic>> requestCartDelete({
  required List<int> ids,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.deletePath,
    data: <String, dynamic>{'ids': ids},
  );
}

/// 按门店拆单创建订单
///
/// [companyIds] 门店 id 列表，[cart] 下单条目数据。
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

/// 更新购物车备注
///
/// [id] 购物车条目 id，[remark] 备注内容。
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

/// 清空指定门店购物车
///
/// [companyId] 门店 id。
Future<Response<dynamic>> requestCartClear({
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CartRequests.clearPath,
    data: <String, dynamic>{'company_id': companyId},
  );
}

/// 获取报价配置
Future<Response<dynamic>> requestQuotationConfig({DioClient? client}) {
  return (client ?? protectedDioClient).get(
    CartRequests.quotationConfigPath,
    simpleResponse: false,
    options: Options(extra: <String, dynamic>{'noCache': true}),
  );
}

/// 导出报价单（二进制文件）
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

/// 导出报价单预览数据
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

/// 加入购物车
///
/// [productId]、[subIndex]、[productNum]、[space]、[subName]
/// 为商品规格与数量参数。
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
      /// `1` 表示开启 SM 检查（后端约定值）。
      'sm_check': 1,
      'all_shop': 1,
    },
  );
}

/// 修改购物车商品规格
///
/// [id] 购物车条目 id，其余参数为新规格信息。
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

/// 为购物车条目设置 SM 信息
///
/// [data] 结构：`[{ shop_department_id, sm_id }, ...]`。
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
