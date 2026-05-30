import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/features/product/services/product_scan_services.dart';

void main() {
  group('ProductScanServices.resolveProductIdFromScan', () {
    test('parses id from hash-route query', () {
      const code =
          'url,https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail?id=64522';

      final id = ProductScanServices.resolveProductIdFromScan(code);

      expect(id, 64522);
    });

    test('parses id from standard query', () {
      const code =
          'url,https://demo.gbuilderchina.com/pages/goods-detail/goods-detail?id=12345';

      final id = ProductScanServices.resolveProductIdFromScan(code);

      expect(id, 12345);
    });

    test('returns null when prefix is not url comma', () {
      const code =
          'https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail?id=64522';

      final id = ProductScanServices.resolveProductIdFromScan(code);

      expect(id, isNull);
    });

    test('returns null when id is missing', () {
      const code =
          'url,https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail';

      final id = ProductScanServices.resolveProductIdFromScan(code);

      expect(id, isNull);
    });

    test('returns null when url is not goods-detail page', () {
      const code =
          'url,https://demo.gbuilderchina.com/m/#/pages/order/index?id=64522';

      final id = ProductScanServices.resolveProductIdFromScan(code);

      expect(id, isNull);
    });
  });
}
