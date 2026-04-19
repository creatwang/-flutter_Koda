import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

/// 门店/站点相关 HTTP 定义（路径、方法、参数形态）。
///
/// 与业务解析、错误映射无关；仅负责发起请求。
class StoreCompanyRequests {
  StoreCompanyRequests._();

  /// 开放列表：`GET /store/company`（无需 token）。
  static const String companyListPath = '/store/company';

  /// 切换店铺：`POST /store/user/switchShop`（需鉴权）。
  static const String switchShopPath = '/store/user/switchShop';
}

/// 请求门店列表（无需认证）。
///
/// 使用 [publicDioClient]；响应经 [DioClient] 默认 `simpleResponse` 解包后，
/// [Response.data] 一般为 `result` 对象：`{ items: [...], total: n }`。
Future<Response<dynamic>> requestStoreCompanyList({
  DioClient? client,
}) {
  return (client ?? publicDioClient).get(
    StoreCompanyRequests.companyListPath,
  );
}

/// 请求切换当前用户所属店铺/站点（需认证）。
///
/// [companyId]：选中门店对应的公司/站点 id，写入请求体 `company_id`。
/// [shopId]：选中门店 id，写入请求体 `shop_id`（与接口约定一致，通常与
/// [companyId] 相同）。
/// [terminal]：终端类型，平板端固定为 `5`。
///
/// 使用 [protectedDioClient]；成功时 [Response.data] 一般为与登录一致的
/// 用户信息 `result`（由拦截器解包）。
Future<Response<dynamic>> requestSwitchShop({
  required int companyId,
  required int shopId,
  int terminal = 5,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    StoreCompanyRequests.switchShopPath,
    data: <String, dynamic>{
      'company_id': companyId,
      'shop_id': shopId,
      'terminal': terminal,
    },
  );
}
