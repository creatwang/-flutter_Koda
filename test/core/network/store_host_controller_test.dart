import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/core/config/env.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('normalizeStoreHost', () {
    test('returns pure host unchanged', () {
      expect(normalizeStoreHost('store.gbuilderchina.com'), 'store.gbuilderchina.com');
    });

    test('strips https scheme and path', () {
      expect(
        normalizeStoreHost('https://store.gbuilderchina.com/api'),
        'store.gbuilderchina.com',
      );
    });

    test('strips http scheme', () {
      expect(
        normalizeStoreHost('http://demo.example.com/foo'),
        'demo.example.com',
      );
    });

    test('returns empty for blank input', () {
      expect(normalizeStoreHost('   '), '');
    });
  });

  group('buildApiBaseUrl', () {
    test('reuses scheme and path prefix from Env.baseUrl', () {
      expect(
        buildApiBaseUrl('store.gbuilderchina.com'),
        '${Env.apiScheme}://store.gbuilderchina.com${Env.apiPathPrefix}',
      );
    });
  });

  group('extractForwardedHostFromScanUrl', () {
    test('extracts host from bare https url', () {
      expect(
        extractForwardedHostFromScanUrl(
          'https://ceramics.georgebuilder.com/search?uniqids=A',
        ),
        'ceramics.georgebuilder.com',
      );
    });

    test('extracts host from url comma prefix', () {
      expect(
        extractForwardedHostFromScanUrl(
          'url,https://demo.gbuilderchina.com/goods-detail?id=1',
        ),
        'demo.gbuilderchina.com',
      );
    });

    test('returns null for non-url payload', () {
      expect(extractForwardedHostFromScanUrl('plain-text'), isNull);
    });
  });

  group('StoreHostController', () {
    late StoreHostController controller;

    setUp(() {
      controller = StoreHostController(
        SecureStorageService(const FlutterSecureStorage()),
      );
    });

    test('applyDomain updates in-memory baseUrl without persist', () async {
      await controller.applyDomain('shop.example.com', persist: false);

      expect(controller.host, 'shop.example.com');
      expect(
        controller.apiBaseUrl,
        '${Env.apiScheme}://shop.example.com${Env.apiPathPrefix}',
      );
    });

    test('resetToDefault restores Env.baseUrl without persist', () async {
      await controller.applyDomain('shop.example.com', persist: false);
      await controller.resetToDefault(persist: false);

      expect(controller.host, isNull);
      expect(controller.apiBaseUrl, Env.baseUrl);
    });

    test('applyDomain throws for empty host', () async {
      expect(
        () => controller.applyDomain('   ', persist: false),
        throwsArgumentError,
      );
    });
  });
}
