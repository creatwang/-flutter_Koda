import 'package:dio/dio.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';

enum ResponseDataMode { origin, simple }

class ResponseDataModeInterceptor extends Interceptor {
  static const String responseDataModeExtraKey = 'response_data_mode';

  /// 为 `true` 时不调用 [showGlobalErrorMessage]（如表单 / BottomSheet 已展示错误）。
  /// 会话过期仍走 [showSessionExpiredDialog]，不受此项影响。
  static const String suppressGlobalErrorMessageExtraKey =
      'suppress_global_error_message';

  ResponseDataModeInterceptor(this.mode);

  final ResponseDataMode mode;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestMode = _resolveRequestMode(response.requestOptions);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (_isSessionExpiredCode(code)) {
        final message = _extractBusinessMessage(data);
        showSessionExpiredDialog(
          message.trim().isEmpty ? '您的登录已过期，请重新登录。' : message,
        );
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
    }

    // origin 模式透传原始业务响应（包含 code/message），由调用方自行判断。
    if (requestMode != ResponseDataMode.simple) {
      handler.next(response);
      return;
    }

    if (data is Map<String, dynamic> && _isBusinessError(data)) {
      final message = _extractBusinessMessage(data);
      if (!_suppressesGlobalError(response.requestOptions)) {
        showGlobalErrorMessage(message);
      }
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
    if (!_isSessionExpiredCode(_extractCode(err.response?.data)) &&
        !_suppressesGlobalError(err.requestOptions)) {
      showGlobalErrorMessage(_extractErrorMessage(err));
    }
    handler.next(err);
  }

  bool _suppressesGlobalError(RequestOptions options) =>
      options.extra[suppressGlobalErrorMessageExtraKey] == true;

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

  dynamic _extractCode(dynamic data) {
    if (data is Map<String, dynamic>) return data['code'];
    return null;
  }

  bool _isSessionExpiredCode(dynamic code) {
    if (code is num) {
      return code == 1000 || code == 1002 || code == 1004 || code == 1102;
    }
    if (code is String) {
      return code == '1000' ||
          code == '1002' ||
          code == '1004' ||
          code == '1102';
    }
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
