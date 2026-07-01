import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';

void main() {
  group('AppRoutes scanHost query', () {
    test('productDetail appends scanHost query param', () {
      final path = AppRoutes.productDetail(
        64522,
        scanHost: 'ceramics.georgebuilder.com',
      );

      expect(path, contains('/product/64522'));
      expect(path, contains('scanHost='));
      expect(path, contains('ceramics.georgebuilder.com'));
    });

    test('productDetail omits query when scanHost is empty', () {
      expect(AppRoutes.productDetail(64522), '/product/64522');
    });

    test('productScanUniqidsList includes scanHost and uniqids', () {
      final path = AppRoutes.productScanUniqidsList(
        ['ECO-1', 'ECO-2'],
        scanHost: 'ceramics.georgebuilder.com',
      );

      expect(path, contains('scanHost='));
      expect(path, contains('uniqids=ECO-1'));
      expect(path, contains('uniqids=ECO-2'));
    });

    test('scanHostFromUri reads scanHost query param', () {
      final uri = Uri.parse(
        '/product/1?scanHost=${Uri.encodeQueryComponent('shop.example.com')}',
      );

      expect(AppRoutes.scanHostFromUri(uri), 'shop.example.com');
    });

    test('scanHostFromUri returns null when missing', () {
      expect(AppRoutes.scanHostFromUri(Uri.parse('/product/1')), isNull);
    });
  });
}
