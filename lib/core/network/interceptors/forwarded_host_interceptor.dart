import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/request_extras.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/network/store_host_routing.dart';

/// 写入 `x-forwarded-host`：仅扫码等请求在 extra 中显式传入时注入。
class ForwardedHostInterceptor extends Interceptor {
  ForwardedHostInterceptor(this._hostController);

  final StoreHostController _hostController;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final host = resolveRequestForwardedHost(
      explicitForwardedHost:
          options.extra[RequestExtras.forwardedHost]?.toString(),
      storeHost: _hostController.host,
    );
    if (host != null && host.isNotEmpty) {
      options.headers['x-forwarded-host'] = host;
    }
    handler.next(options);
  }
}
