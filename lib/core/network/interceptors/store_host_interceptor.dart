import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/network/store_host_routing.dart';

/// 每请求注入当前站点 API 根地址。
class StoreHostInterceptor extends Interceptor {
  StoreHostInterceptor(this._hostController);

  final StoreHostController _hostController;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.baseUrl = resolveRequestBaseUrl(
      storeApiBaseUrl: _hostController.apiBaseUrl,
    );
    handler.next(options);
  }
}
