import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ListFormat.multiCompatible encodes uniqids as array pairs', () {
    final query = Transformer.urlEncodeQueryMap(
      <String, dynamic>{
        'shop_category_id': 0,
        'page': 1,
        'uniqids': <String>['AAW7029', 'AAW7028'],
      },
      ListFormat.multiCompatible,
    );

    expect(query, contains('uniqids[]=AAW7029'));
    expect(query, contains('uniqids[]=AAW7028'));
  });
}
