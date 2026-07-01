import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/core/network/store_host_routing.dart';

void main() {
  const envBaseUrl = 'https://store.gbuilderchina.com/testapi';

  group('resolveRequestBaseUrl', () {
    test('native uses store api base url', () {
      expect(
        resolveRequestBaseUrl(
          storeApiBaseUrl: 'https://ceramics.example.com/testapi',
          isWeb: false,
          envBaseUrl: envBaseUrl,
        ),
        'https://ceramics.example.com/testapi',
      );
    });

    test('web always uses env gateway', () {
      expect(
        resolveRequestBaseUrl(
          storeApiBaseUrl: 'https://ceramics.example.com/testapi',
          isWeb: true,
          envBaseUrl: envBaseUrl,
        ),
        envBaseUrl,
      );
    });
  });

  group('resolveSessionForwardedHost', () {
    test('native returns null', () {
      expect(
        resolveSessionForwardedHost(
          storeHost: 'ceramics.example.com',
          isWeb: false,
          envBaseUrl: envBaseUrl,
        ),
        isNull,
      );
    });

    test('web returns null when store host equals gateway host', () {
      expect(
        resolveSessionForwardedHost(
          storeHost: 'store.gbuilderchina.com',
          isWeb: true,
          envBaseUrl: envBaseUrl,
        ),
        isNull,
      );
    });

    test('web returns store host when different from gateway', () {
      expect(
        resolveSessionForwardedHost(
          storeHost: 'ceramics.example.com',
          isWeb: true,
          envBaseUrl: envBaseUrl,
        ),
        'ceramics.example.com',
      );
    });
  });

  group('resolveRequestForwardedHost', () {
    test('explicit scan host wins on web', () {
      expect(
        resolveRequestForwardedHost(
          explicitForwardedHost: 'scan.example.com',
          storeHost: 'ceramics.example.com',
          isWeb: true,
          envBaseUrl: envBaseUrl,
        ),
        'scan.example.com',
      );
    });

    test('falls back to session store host on web', () {
      expect(
        resolveRequestForwardedHost(
          explicitForwardedHost: null,
          storeHost: 'ceramics.example.com',
          isWeb: true,
          envBaseUrl: envBaseUrl,
        ),
        'ceramics.example.com',
      );
    });
  });
}
