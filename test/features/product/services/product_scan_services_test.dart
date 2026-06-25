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

    test('parses bare https url without url comma prefix', () {
      const code =
          'https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail?id=64521';

      final id = ProductScanServices.resolveProductIdFromScan(code);

      expect(id, 64521);
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

  group('ProductScanServices.resolveUniqidsFromScan', () {
    test('parses uniqids from ceramics scan url', () {
      const code =
          'https://ceramics.georgebuilder.com/uniqids=GM-NT673-FF&GM-FQ019F-FF';

      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);

      expect(uniqids, ['GM-NT673-FF', 'GM-FQ019F-FF']);
    });

    test('parses uniqids with url comma prefix', () {
      const code =
          'url,https://ceramics.georgebuilder.com/uniqids=GM-NT673-FF&GM-FQ019F-FF';

      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);

      expect(uniqids, ['GM-NT673-FF', 'GM-FQ019F-FF']);
    });

    test('returns null when last path segment is not uniqids', () {
      const code = 'https://ceramics.georgebuilder.com/products/list';

      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);

      expect(uniqids, isNull);
    });
  });

  group('ProductScanServices.resolveFromScan', () {
    test('prefers uniqids over goods-detail id', () {
      const code =
          'https://ceramics.georgebuilder.com/uniqids=GM-NT673-FF&GM-FQ019F-FF';

      final resolved = ProductScanServices.resolveFromScan(code);

      expect(resolved, isA<ProductScanResolveUniqids>());
      expect(
        (resolved as ProductScanResolveUniqids).uniqids,
        ['GM-NT673-FF', 'GM-FQ019F-FF'],
      );
    });

    test('falls back to product id for goods-detail url', () {
      const code =
          'https://demo.gbuilderchina.com/pages/goods-detail/goods-detail?id=12345';

      final resolved = ProductScanServices.resolveFromScan(code);

      expect(resolved, isA<ProductScanResolveProductId>());
      expect((resolved as ProductScanResolveProductId).productId, 12345);
    });
  });
}
