import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/core/network/interceptors/forwarded_host_interceptor.dart';
import 'package:george_pick_mate/core/network/request_extras.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('ForwardedHostInterceptor', () {
    late StoreHostController hostController;

    setUp(() {
      hostController = StoreHostController(
        SecureStorageService(const FlutterSecureStorage()),
      );
    });

    test('sets x-forwarded-host when extra contains forwardedHost', () async {
      await hostController.applyDomain('session.example.com', persist: false);
      final interceptor = ForwardedHostInterceptor(hostController);
      final options = RequestOptions(
        path: '/store/product/detail',
        extra: <String, dynamic>{
          RequestExtras.forwardedHost: 'ceramics.georgebuilder.com',
        },
      );

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(
        options.headers['x-forwarded-host'],
        'ceramics.georgebuilder.com',
      );
    });

    test('does not set header when extra is absent and no store host', () {
      final interceptor = ForwardedHostInterceptor(hostController);
      final options = RequestOptions(path: '/store/product/lists');

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers.containsKey('x-forwarded-host'), false);
    });
  });
}
