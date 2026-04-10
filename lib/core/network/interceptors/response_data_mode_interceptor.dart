import 'package:dio/dio.dart';
import 'package:groe_app_pad/shared/services/app_message_service.dart';

enum ResponseDataMode { origin, simple }

class ResponseDataModeInterceptor extends Interceptor {
  static const String responseDataModeExtraKey = 'response_data_mode';

  ResponseDataModeInterceptor(this.mode);

  final ResponseDataMode mode;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestMode = _resolveRequestMode(response.requestOptions);
    final data = response.data;
    if (data is Map<String, dynamic> && _isBusinessError(data)) {
      final message = _extractBusinessMessage(data);
      showGlobalErrorMessage(message);
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: message,
          message: message,
        ),
      );
      return;
    }

    if (requestMode == ResponseDataMode.simple) {
      if (data is Map<String, dynamic> && data.containsKey('result')) {
        response.data = data['result'];
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    showGlobalErrorMessage(_extractErrorMessage(err));
    handler.next(err);
  }

  ResponseDataMode _resolveRequestMode(RequestOptions options) {
    final override = options.extra[responseDataModeExtraKey];
    if (override is ResponseDataMode) return override;
    if (override is String) {
      if (override == ResponseDataMode.simple.name) return ResponseDataMode.simple;
      if (override == ResponseDataMode.origin.name) return ResponseDataMode.origin;
    }
    return mode;
  }

  bool _isBusinessError(Map<String, dynamic> data) {
    final code = data['code'];
    if (code is num) return code != 0;
    if (code is String) return code != '0' && code.toLowerCase() != 'success';
    return false;
  }

  String _extractBusinessMessage(Map<String, dynamic> data) {
    final raw = data['message'] ?? data['msg'] ?? data['error'];
    if (raw is String && raw.trim().isNotEmpty) return raw;
    return 'Request failed';
  }

  String _extractErrorMessage(DioException err) {
    final responseData = err.response?.data;
    if (responseData is Map<String, dynamic>) {
      final msg = responseData['message'] ?? responseData['msg'] ?? responseData['error'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
    }
    if (err.message != null && err.message!.trim().isNotEmpty) {
      return err.message!;
    }
    return 'Network error';
  }
}
