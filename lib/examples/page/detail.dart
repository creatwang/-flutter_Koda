

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';


/// product_sub 生成参数路径
/// product 产品集合
/// id：默认选中的产品id
class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final detailInfo = getJson()['result'] as Map<String, dynamic>? ?? <String, dynamic>{};
  // 1. 解析原始数据并进行类型转换
  late final productSub = detailInfo['product_sub'] as List? ?? const [];
  late final product = detailInfo['product'] as List? ?? const [];
  late var detailId = (detailInfo['id'] as num?)?.toInt() ?? 0;
  late final Map<String, String> optionPath = {
    for (final item in productSub.whereType<Map>())
      item['pid']?.toString() ?? '': item['_index']?.toString() ?? ''
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('详情页面')),
      body: Center(
        child: ProductSkuOption(
            productList: product,
            id: detailId,
            optionPath: optionPath[detailId.toString()] ?? '',
            onChange: (id) {
              setState(() {
                detailId = id;
              });
            },
        ),
      ),
    );
  }
}


class ProductSkuOption extends StatefulWidget {
  final List<dynamic> productList;
  final int id;
  final String optionPath;
  final Function(int id) onChange;
  const ProductSkuOption({
    required this.onChange,
    required this.productList,
    required this.id,
    required this.optionPath
    , super.key});

  @override
  State<ProductSkuOption> createState() => _ProductSkuOptionState();
}

class _ProductSkuOptionState extends State<ProductSkuOption> {
  late int _selectedId;
  List<dynamic> options = const [];

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _firstPid(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return _asInt(value.first);
    }
    return _asInt(value);
  }

  List<Map<String, dynamic>> _normalizeMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    }
    if (value is Map) {
      return value.entries
          .map(
            (entry) => <String, dynamic>{
          'key': entry.key,
          'value': entry.value,
        },
      )
          .toList(growable: false);
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _selectedId = widget.id;
    _syncOptionsBySelectedId();
  }

  @override
  void didUpdateWidget(covariant ProductSkuOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productList != widget.productList || oldWidget.id != widget.id) {
      _selectedId = widget.id;
      _syncOptionsBySelectedId();
    }
  }

  void _syncOptionsBySelectedId() {
    final products = _normalizeMapList(widget.productList);
    final selected = products
        .firstWhereOrNull((el) => (el['id'] as num?)?.toInt() == _selectedId);
    options = _normalizeMapList(selected?['spec_value']);
  }

  @override
  Widget build(BuildContext context) {
    final products = _normalizeMapList(widget.productList);
    final optionItems = _normalizeMapList(options);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product:'),
        if (products.isEmpty)
          const Text('No product data')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: products.mapIndexed((idx, el) {
              final productId = _asInt(el['id']);
              final isSelected = productId != null && _selectedId == productId;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: productId == null
                    ? null
                    : () {
                        setState(() {
                          _selectedId = productId;
                          options = _normalizeMapList(el['spec_value']);
                        });
                        widget.onChange(productId);
                      },
                child: Text(el['name']?.toString() ?? 'Product ${idx + 1}'),
              );
            }).toList(growable: false),
          ),
        ...optionItems.map((el) {
          final optionButtons = _normalizeMapList(el['options']);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(el['name']?.toString() ?? ''),
              Row(
                children: optionButtons.map((option) {
                  final spec = option['spec']?.toString() ?? '';
                  final isSelected =
                      spec.isNotEmpty && widget.optionPath.contains(spec);
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.black,
                      foregroundColor: Colors.white, // 别忘了文字颜色，黑色背景下默认文字可能看不清
                    ),
                    onPressed: () {
                      final pid = _firstPid(option['pid']);
                      if (pid != null) {
                        widget.onChange(pid);
                      }
                    },
                    child: Text(option['name']?.toString() ?? ''),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }
}



Map<String, dynamic> getJson() {
  const json = '''
  {
  "code": 0,
  "message": "ok",
  "type": "success",
  "result": {
  "id": 117276,
  "category_id": 3065,
  "name": "1+3+Imperial Concubine Position",
  "name_cn": "1+3+\u8d35\u5983\u4f4d",
  "unit": "pcs",
  "uniqid": "ECO-SOF-DP-YY0S63",
  "detail_images": null,
  "parent_uniqid": "",
  "is_hot": 0,
  "sort_order": 999,
  "basic_dept_id": 110,
  "product_sub": [
  {
  "pid": 117276,
  "model": "ECO-SOF-DP-YY0S63",
  "index": "a0",
  "status": 1,
  "image": null,
  "sale_price_tax": 1414200,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "cny_sales_price": 12738,
  "exchange_price": 1864.11,
  "sales_price": 2123,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 14142,
  "sales_price_tax": 2357,
  "name": "1+3+Imperial Concubine Position",
  "name_cn": "1+3+Imperial Concubine Position",
  "_index": "a0_b0"
  },
  {
  "basic_dept_id": 110,
  "pid": 117277,
  "model": "ECO-SOF-DP-YY0S63-1",
  "index": "a0",
  "cost_max": 0,
  "tax": 10,
  "sale_price_tax": 696600,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "estimated_price_range": "",
  "estimated_price_range_min": 0,
  "estimated_price_range_max": 0,
  "recent_price": 0,
  "status": 1,
  "deleted_at": null,
  "image": null,
  "is_change": 0,
  "cny_sales_price": 6270,
  "exchange_price": 917.57,
  "sales_price": 1045,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 6966,
  "sales_price_tax": 1161,
  "cost_price": 348.33,
  "cost_tax_price": 387,
  "name": "Three-person seat",
  "name_cn": "Three-person seat",
  "_index": "a1_b0"
  },
  {
  "basic_dept_id": 110,
  "pid": 117278,
  "model": "ECO-SOF-DP-YY0S63-2",
  "index": "a0",
  "cost_max": 0,
  "tax": 10,
  "sale_price_tax": 591900,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "estimated_price_range": "",
  "estimated_price_range_min": 0,
  "estimated_price_range_max": 0,
  "recent_price": 0,
  "status": 1,
  "deleted_at": null,
  "image": null,
  "is_change": 0,
  "cny_sales_price": 5328,
  "exchange_price": 779.71,
  "sales_price": 888,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 5919,
  "sales_price_tax": 986.5,
  "cost_price": 296,
  "cost_tax_price": 328.83,
  "name": "Two-person seat",
  "name_cn": "Two-person seat",
  "_index": "a3_b0"
  },
  {
  "basic_dept_id": 110,
  "pid": 117279,
  "model": "ECO-SOF-DP-YY0S63-3",
  "index": "a0",
  "cost_max": 0,
  "tax": 10,
  "sale_price_tax": 557100,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "estimated_price_range": "",
  "estimated_price_range_min": 0,
  "estimated_price_range_max": 0,
  "recent_price": 0,
  "status": 1,
  "deleted_at": null,
  "image": null,
  "is_change": 0,
  "cny_sales_price": 5016,
  "exchange_price": 734.05,
  "sales_price": 836,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 5571,
  "sales_price_tax": 928.5,
  "cost_price": 278.67,
  "cost_tax_price": 309.5,
  "name": "Single seat",
  "name_cn": "Single seat",
  "_index": "a2_b0"
  }
  ],
  "shop_product_descs": null,
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63/177593636569cf21002cddf772274834.png",
  "sub_images": [
  "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63/177593636569cf21002cddf772274834.png"
  ],
  "price": 836,
  "max_price": 2123,
  "cny_price": 12738,
  "category_name": "Sofa",
  "formula_type": "",
  "product": [
  {
  "id": 117276,
  "name": "1+3+Imperial Concubine Position",
  "name_cn": "1+3+\u8d35\u5983\u4f4d",
  "uniqid": "ECO-SOF-DP-YY0S63",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63/177593636569cf21002cddf772274834.png",
  "detail_images": null,
  "sub_images": [
  "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63/177593636569cf21002cddf772274834.png"
  ],
  "category_name": "Sofa",
  "formula_type": "",
  "category_id": 3065,
  "price": 836,
  "unit": "pcs",
  "max_price": 2123,
  "is_hot": 0,
  "parent_uniqid": "",
  "is_attr_product": 0,
  "basic_dept_id": 110,
  "product_param": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "3350",
  "value_cn": "3350",
  "pid": 117276,
  "name": "Length(mm)",
  "value": "3350"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "1750",
  "value_cn": "1750",
  "pid": 117276,
  "name": "Width(mm)",
  "value": "1750"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117276,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117276,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117276,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117276,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117276,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117276,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "2.5",
  "value_cn": "2.5",
  "pid": 117276,
  "name": "CBM(m\u00b3)",
  "value": "2.5"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "180",
  "value_cn": "180",
  "pid": 117276,
  "name": "Estimated net weight KG",
  "value": "180"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "185",
  "value_cn": "185",
  "pid": 117276,
  "name": "Weight(kg)",
  "value": "185"
  }
  ],
  "product_param_edit": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "3350",
  "value_cn": "3350",
  "pid": 117276,
  "name": "Length(mm)",
  "value": "3350"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "1750",
  "value_cn": "1750",
  "pid": 117276,
  "name": "Width(mm)",
  "value": "1750"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117276,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117276,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117276,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117276,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117276,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117276,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "2.5",
  "value_cn": "2.5",
  "pid": 117276,
  "name": "CBM(m\u00b3)",
  "value": "2.5"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "180",
  "value_cn": "180",
  "pid": 117276,
  "name": "Estimated net weight KG",
  "value": "180"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "185",
  "value_cn": "185",
  "pid": 117276,
  "name": "Weight(kg)",
  "value": "185"
  },
  {
  "name_en": "Product size",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8",
  "value_en": "L3350*W1750*H880",
  "value_cn": "\u957f3350*\u5bbd1750*\u9ad8880",
  "pid": 117276,
  "name": "Product size",
  "value": "L3350*W1750*H880"
  }
  ],
  "sort_order": 999,
  "shop_product_descs": null,
  "goods_detail_card": [
  {
  "title": "DIMENSIONS",
  "type": "param",
  "content": [
  {
  "name": "Product size(mm)",
  "value": "L3350*W1750*H880"
  },
  {
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  }
  ]
  },
  {
  "title": "OVERVIEWS",
  "type": "html",
  "content": ""
  },
  {
  "title": "DETAILS",
  "type": "html",
  "content": ""
  }
  ],
  "spec_value": [
  {
  "type": "param",
  "name": "Product size(mm)",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8(mm)",
  "attr_index": "a",
  "options": [
  {
  "pid": [
  117276
  ],
  "name": "L3350*W1750*H880",
  "name_cn": "L3350*W1750*H880",
  "attr_index": "a",
  "spec": "a0"
  },
  {
  "pid": [
  117277
  ],
  "name": "L2220*W930*H880",
  "name_cn": "L2220*W930*H880",
  "attr_index": "a",
  "spec": "a1"
  },
  {
  "pid": [
  117279
  ],
  "name": "L1130*W930*H880",
  "name_cn": "L1130*W930*H880",
  "attr_index": "a",
  "spec": "a2"
  },
  {
  "pid": [
  117278
  ],
  "name": "L1730*W930*H880",
  "name_cn": "L1730*W930*H880",
  "attr_index": "a",
  "spec": "a3"
  }
  ]
  },
  {
  "type": "param",
  "name": "Material",
  "name_cn": "\u6750\u8d28",
  "attr_index": "b",
  "options": [
  {
  "pid": [
  117276,
  117277,
  117279,
  117278
  ],
  "name": "Artificial leather+sponge+Pine wood+stainless steel",
  "name_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "attr_index": "b",
  "spec": "b0"
  }
  ]
  }
  ],
  "product_sub": [
  {
  "pid": 117276,
  "model": "ECO-SOF-DP-YY0S63",
  "index": "a0",
  "status": 1,
  "image": null,
  "sale_price_tax": 1414200,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "cny_sales_price": 12738,
  "exchange_price": 1864.11,
  "sales_price": 2123,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 14142,
  "sales_price_tax": 2357,
  "name": "1+3+Imperial Concubine Position",
  "name_cn": "1+3+Imperial Concubine Position",
  "_index": "a0_b0"
  }
  ],
  "is_collect": false,
  "extra_params": []
  },
  {
  "id": 117277,
  "name": "Three-person seat",
  "name_cn": "\u4e09\u4eba\u4f4d",
  "uniqid": "ECO-SOF-DP-YY0S63-1",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63-1/177572771069cf210414a05905876400.png",
  "detail_images": null,
  "sub_images": [
  "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63-1/177572771069cf210414a05905876400.png"
  ],
  "category_name": "",
  "formula_type": "",
  "category_id": 3065,
  "price": 1045,
  "unit": "pcs",
  "max_price": 1045,
  "is_hot": 0,
  "parent_uniqid": "ECO-SOF-DP-YY0S63",
  "is_attr_product": 0,
  "basic_dept_id": 110,
  "product_param": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "2220",
  "value_cn": "2220",
  "pid": 117277,
  "name": "Length(mm)",
  "value": "2220"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "930",
  "value_cn": "930",
  "pid": 117277,
  "name": "Width(mm)",
  "value": "930"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117277,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117277,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117277,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117277,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117277,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117277,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "1.5",
  "value_cn": "1.5",
  "pid": 117277,
  "name": "CBM(m\u00b3)",
  "value": "1.5"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "100",
  "value_cn": "100",
  "pid": 117277,
  "name": "Estimated net weight KG",
  "value": "100"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "105",
  "value_cn": "105",
  "pid": 117277,
  "name": "Weight(kg)",
  "value": "105"
  }
  ],
  "product_param_edit": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "2220",
  "value_cn": "2220",
  "pid": 117277,
  "name": "Length(mm)",
  "value": "2220"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "930",
  "value_cn": "930",
  "pid": 117277,
  "name": "Width(mm)",
  "value": "930"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117277,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117277,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117277,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117277,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117277,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117277,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "1.5",
  "value_cn": "1.5",
  "pid": 117277,
  "name": "CBM(m\u00b3)",
  "value": "1.5"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "100",
  "value_cn": "100",
  "pid": 117277,
  "name": "Estimated net weight KG",
  "value": "100"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "105",
  "value_cn": "105",
  "pid": 117277,
  "name": "Weight(kg)",
  "value": "105"
  },
  {
  "name_en": "Product size",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8",
  "value_en": "L2220*W930*H880",
  "value_cn": "\u957f2220*\u5bbd930*\u9ad8880",
  "pid": 117277,
  "name": "Product size",
  "value": "L2220*W930*H880"
  }
  ],
  "sort_order": 999,
  "shop_product_descs": null,
  "goods_detail_card": [
  {
  "title": "DIMENSIONS",
  "type": "param",
  "content": [
  {
  "name": "Product size(mm)",
  "value": "L2220*W930*H880"
  },
  {
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  }
  ]
  },
  {
  "title": "OVERVIEWS",
  "type": "html",
  "content": ""
  },
  {
  "title": "DETAILS",
  "type": "html",
  "content": ""
  }
  ],
  "spec_value": [
  {
  "type": "param",
  "name": "Product size(mm)",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8(mm)",
  "attr_index": "a",
  "options": [
  {
  "pid": [
  117276
  ],
  "name": "L3350*W1750*H880",
  "name_cn": "L3350*W1750*H880",
  "attr_index": "a",
  "spec": "a0"
  },
  {
  "pid": [
  117277
  ],
  "name": "L2220*W930*H880",
  "name_cn": "L2220*W930*H880",
  "attr_index": "a",
  "spec": "a1"
  },
  {
  "pid": [
  117279
  ],
  "name": "L1130*W930*H880",
  "name_cn": "L1130*W930*H880",
  "attr_index": "a",
  "spec": "a2"
  },
  {
  "pid": [
  117278
  ],
  "name": "L1730*W930*H880",
  "name_cn": "L1730*W930*H880",
  "attr_index": "a",
  "spec": "a3"
  }
  ]
  },
  {
  "type": "param",
  "name": "Material",
  "name_cn": "\u6750\u8d28",
  "attr_index": "b",
  "options": [
  {
  "pid": [
  117276,
  117277,
  117279,
  117278
  ],
  "name": "Artificial leather+sponge+Pine wood+stainless steel",
  "name_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "attr_index": "b",
  "spec": "b0"
  }
  ]
  }
  ],
  "product_sub": [
  {
  "basic_dept_id": 110,
  "pid": 117277,
  "model": "ECO-SOF-DP-YY0S63-1",
  "index": "a0",
  "cost_max": 0,
  "tax": 10,
  "sale_price_tax": 696600,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "estimated_price_range": "",
  "estimated_price_range_min": 0,
  "estimated_price_range_max": 0,
  "recent_price": 0,
  "status": 1,
  "deleted_at": null,
  "image": null,
  "is_change": 0,
  "cny_sales_price": 6270,
  "exchange_price": 917.57,
  "sales_price": 1045,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 6966,
  "sales_price_tax": 1161,
  "cost_price": 348.33,
  "cost_tax_price": 387,
  "name": "Three-person seat",
  "name_cn": "Three-person seat",
  "_index": "a1_b0"
  }
  ],
  "is_collect": false,
  "extra_params": []
  },
  {
  "id": 117278,
  "name": "Two-person seat",
  "name_cn": "\u53cc\u4eba\u4f4d",
  "uniqid": "ECO-SOF-DP-YY0S63-2",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63-2/177553242369cf2124249d8268701908.png",
  "detail_images": null,
  "sub_images": [
  "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63-2/177553242369cf2124249d8268701908.png"
  ],
  "category_name": "",
  "formula_type": "",
  "category_id": 3065,
  "price": 888,
  "unit": "pcs",
  "max_price": 888,
  "is_hot": 0,
  "parent_uniqid": "ECO-SOF-DP-YY0S63",
  "is_attr_product": 0,
  "basic_dept_id": 110,
  "product_param": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "1730",
  "value_cn": "1730",
  "pid": 117278,
  "name": "Length(mm)",
  "value": "1730"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "930",
  "value_cn": "930",
  "pid": 117278,
  "name": "Width(mm)",
  "value": "930"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117278,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117278,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117278,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117278,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117278,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117278,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "1.2",
  "value_cn": "1.2",
  "pid": 117278,
  "name": "CBM(m\u00b3)",
  "value": "1.2"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "90",
  "value_cn": "90",
  "pid": 117278,
  "name": "Estimated net weight KG",
  "value": "90"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "95",
  "value_cn": "95",
  "pid": 117278,
  "name": "Weight(kg)",
  "value": "95"
  }
  ],
  "product_param_edit": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "1730",
  "value_cn": "1730",
  "pid": 117278,
  "name": "Length(mm)",
  "value": "1730"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "930",
  "value_cn": "930",
  "pid": 117278,
  "name": "Width(mm)",
  "value": "930"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117278,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117278,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117278,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117278,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117278,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117278,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "1.2",
  "value_cn": "1.2",
  "pid": 117278,
  "name": "CBM(m\u00b3)",
  "value": "1.2"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "90",
  "value_cn": "90",
  "pid": 117278,
  "name": "Estimated net weight KG",
  "value": "90"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "95",
  "value_cn": "95",
  "pid": 117278,
  "name": "Weight(kg)",
  "value": "95"
  },
  {
  "name_en": "Product size",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8",
  "value_en": "L1730*W930*H880",
  "value_cn": "\u957f1730*\u5bbd930*\u9ad8880",
  "pid": 117278,
  "name": "Product size",
  "value": "L1730*W930*H880"
  }
  ],
  "sort_order": 999,
  "shop_product_descs": null,
  "goods_detail_card": [
  {
  "title": "DIMENSIONS",
  "type": "param",
  "content": [
  {
  "name": "Product size(mm)",
  "value": "L1730*W930*H880"
  },
  {
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  }
  ]
  },
  {
  "title": "OVERVIEWS",
  "type": "html",
  "content": ""
  },
  {
  "title": "DETAILS",
  "type": "html",
  "content": ""
  }
  ],
  "spec_value": [
  {
  "type": "param",
  "name": "Product size(mm)",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8(mm)",
  "attr_index": "a",
  "options": [
  {
  "pid": [
  117276
  ],
  "name": "L3350*W1750*H880",
  "name_cn": "L3350*W1750*H880",
  "attr_index": "a",
  "spec": "a0"
  },
  {
  "pid": [
  117277
  ],
  "name": "L2220*W930*H880",
  "name_cn": "L2220*W930*H880",
  "attr_index": "a",
  "spec": "a1"
  },
  {
  "pid": [
  117279
  ],
  "name": "L1130*W930*H880",
  "name_cn": "L1130*W930*H880",
  "attr_index": "a",
  "spec": "a2"
  },
  {
  "pid": [
  117278
  ],
  "name": "L1730*W930*H880",
  "name_cn": "L1730*W930*H880",
  "attr_index": "a",
  "spec": "a3"
  }
  ]
  },
  {
  "type": "param",
  "name": "Material",
  "name_cn": "\u6750\u8d28",
  "attr_index": "b",
  "options": [
  {
  "pid": [
  117276,
  117277,
  117279,
  117278
  ],
  "name": "Artificial leather+sponge+Pine wood+stainless steel",
  "name_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "attr_index": "b",
  "spec": "b0"
  }
  ]
  }
  ],
  "product_sub": [
  {
  "basic_dept_id": 110,
  "pid": 117278,
  "model": "ECO-SOF-DP-YY0S63-2",
  "index": "a0",
  "cost_max": 0,
  "tax": 10,
  "sale_price_tax": 591900,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "estimated_price_range": "",
  "estimated_price_range_min": 0,
  "estimated_price_range_max": 0,
  "recent_price": 0,
  "status": 1,
  "deleted_at": null,
  "image": null,
  "is_change": 0,
  "cny_sales_price": 5328,
  "exchange_price": 779.71,
  "sales_price": 888,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 5919,
  "sales_price_tax": 986.5,
  "cost_price": 296,
  "cost_tax_price": 328.83,
  "name": "Two-person seat",
  "name_cn": "Two-person seat",
  "_index": "a3_b0"
  }
  ],
  "is_collect": false,
  "extra_params": []
  },
  {
  "id": 117279,
  "name": "Single seat",
  "name_cn": "\u5355\u4eba\u4f4d",
  "uniqid": "ECO-SOF-DP-YY0S63-3",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63-3/177615066269cf2127c154e529236277.png",
  "detail_images": null,
  "sub_images": [
  "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0S63-3/177615066269cf2127c154e529236277.png"
  ],
  "category_name": "",
  "formula_type": "",
  "category_id": 3065,
  "price": 836,
  "unit": "pcs",
  "max_price": 836,
  "is_hot": 0,
  "parent_uniqid": "ECO-SOF-DP-YY0S63",
  "is_attr_product": 0,
  "basic_dept_id": 110,
  "product_param": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "1130",
  "value_cn": "1130",
  "pid": 117279,
  "name": "Length(mm)",
  "value": "1130"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "930",
  "value_cn": "930",
  "pid": 117279,
  "name": "Width(mm)",
  "value": "930"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117279,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117279,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117279,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117279,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117279,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117279,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "1",
  "value_cn": "1",
  "pid": 117279,
  "name": "CBM(m\u00b3)",
  "value": "1"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "70",
  "value_cn": "70",
  "pid": 117279,
  "name": "Estimated net weight KG",
  "value": "70"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "75",
  "value_cn": "75",
  "pid": 117279,
  "name": "Weight(kg)",
  "value": "75"
  }
  ],
  "product_param_edit": [
  {
  "name_en": "Length(mm)",
  "name_cn": "\u957f\u5ea6",
  "value_en": "1130",
  "value_cn": "1130",
  "pid": 117279,
  "name": "Length(mm)",
  "value": "1130"
  },
  {
  "name_en": "Width(mm)",
  "name_cn": "\u5bbd\u5ea6",
  "value_en": "930",
  "value_cn": "930",
  "pid": 117279,
  "name": "Width(mm)",
  "value": "930"
  },
  {
  "name_en": "Height(mm)",
  "name_cn": "\u9ad8\u5ea6",
  "value_en": "880",
  "value_cn": "880",
  "pid": 117279,
  "name": "Height(mm)",
  "value": "880"
  },
  {
  "name_en": "Material",
  "name_cn": "\u6750\u8d28",
  "value_en": "Artificial leather+sponge+Pine wood+stainless steel",
  "value_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "pid": 117279,
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  },
  {
  "name_en": "assemble",
  "name_cn": "\u662f\u5426\u9700\u8981\u5b89\u88c5",
  "value_en": "No",
  "value_cn": "\u5426",
  "pid": 117279,
  "name": "assemble",
  "value": "No"
  },
  {
  "name_en": "Frame material",
  "name_cn": "\u6846\u67b6\u6750\u8d28",
  "value_en": "Larch+stainless steel",
  "value_cn": "\u843d\u53f6\u677e+\u4e0d\u9508\u94a2",
  "pid": 117279,
  "name": "Frame material",
  "value": "Larch+stainless steel"
  },
  {
  "name_en": "Filling material",
  "name_cn": "\u586b\u5145\u6750\u8d28",
  "value_en": "sponge",
  "value_cn": "\u6d77\u7ef5",
  "pid": 117279,
  "name": "Filling material",
  "value": "sponge"
  },
  {
  "name_en": "Leg Material",
  "name_cn": "\u5e95\u811a\u6750\u8d28",
  "value_en": "stainless steel",
  "value_cn": "\u4e0d\u9508\u94a2",
  "pid": 117279,
  "name": "Leg Material",
  "value": "stainless steel"
  },
  {
  "name_en": "CBM(m\u00b3)",
  "name_cn": "\u9884\u4f30CBMm\u00b3",
  "value_en": "1",
  "value_cn": "1",
  "pid": 117279,
  "name": "CBM(m\u00b3)",
  "value": "1"
  },
  {
  "name_en": "Estimated net weight KG",
  "name_cn": "\u9884\u4f30\u51c0\u91cdKG",
  "value_en": "70",
  "value_cn": "70",
  "pid": 117279,
  "name": "Estimated net weight KG",
  "value": "70"
  },
  {
  "name_en": "Weight(kg)",
  "name_cn": "\u9884\u4f30\u6bdb\u91cdKG",
  "value_en": "75",
  "value_cn": "75",
  "pid": 117279,
  "name": "Weight(kg)",
  "value": "75"
  },
  {
  "name_en": "Product size",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8",
  "value_en": "L1130*W930*H880",
  "value_cn": "\u957f1130*\u5bbd930*\u9ad8880",
  "pid": 117279,
  "name": "Product size",
  "value": "L1130*W930*H880"
  }
  ],
  "sort_order": 999,
  "shop_product_descs": null,
  "goods_detail_card": [
  {
  "title": "DIMENSIONS",
  "type": "param",
  "content": [
  {
  "name": "Product size(mm)",
  "value": "L1130*W930*H880"
  },
  {
  "name": "Material",
  "value": "Artificial leather+sponge+Pine wood+stainless steel"
  }
  ]
  },
  {
  "title": "OVERVIEWS",
  "type": "html",
  "content": ""
  },
  {
  "title": "DETAILS",
  "type": "html",
  "content": ""
  }
  ],
  "spec_value": [
  {
  "type": "param",
  "name": "Product size(mm)",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8(mm)",
  "attr_index": "a",
  "options": [
  {
  "pid": [
  117276
  ],
  "name": "L3350*W1750*H880",
  "name_cn": "L3350*W1750*H880",
  "attr_index": "a",
  "spec": "a0"
  },
  {
  "pid": [
  117277
  ],
  "name": "L2220*W930*H880",
  "name_cn": "L2220*W930*H880",
  "attr_index": "a",
  "spec": "a1"
  },
  {
  "pid": [
  117279
  ],
  "name": "L1130*W930*H880",
  "name_cn": "L1130*W930*H880",
  "attr_index": "a",
  "spec": "a2"
  },
  {
  "pid": [
  117278
  ],
  "name": "L1730*W930*H880",
  "name_cn": "L1730*W930*H880",
  "attr_index": "a",
  "spec": "a3"
  }
  ]
  },
  {
  "type": "param",
  "name": "Material",
  "name_cn": "\u6750\u8d28",
  "attr_index": "b",
  "options": [
  {
  "pid": [
  117276,
  117277,
  117279,
  117278
  ],
  "name": "Artificial leather+sponge+Pine wood+stainless steel",
  "name_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "attr_index": "b",
  "spec": "b0"
  }
  ]
  }
  ],
  "product_sub": [
  {
  "basic_dept_id": 110,
  "pid": 117279,
  "model": "ECO-SOF-DP-YY0S63-3",
  "index": "a0",
  "cost_max": 0,
  "tax": 10,
  "sale_price_tax": 557100,
  "estimated_price": 0,
  "estimated_price_tax": 0,
  "estimated_price_range": "",
  "estimated_price_range_min": 0,
  "estimated_price_range_max": 0,
  "recent_price": 0,
  "status": 1,
  "deleted_at": null,
  "image": null,
  "is_change": 0,
  "cny_sales_price": 5016,
  "exchange_price": 734.05,
  "sales_price": 836,
  "cny_estimated_price": 0,
  "cny_estimated_price_tax": 0,
  "cny_sale_price_tax": 5571,
  "sales_price_tax": 928.5,
  "cost_price": 278.67,
  "cost_tax_price": 309.5,
  "name": "Single seat",
  "name_cn": "Single seat",
  "_index": "a2_b0"
  }
  ],
  "is_collect": false,
  "extra_params": []
  }
  ],
  "match_products": [
  {
  "id": 117307,
  "name": "Single seat",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY0QS606-2/177569414269cf21be8ca1e445275622.png",
  "price": 840,
  "max_price": 840
  },
  {
  "id": 117306,
  "name": "Three-person seat",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY01815/177556648869cf21bab2887682551532.png",
  "price": 2690,
  "max_price": 2690
  },
  {
  "id": 117305,
  "name": "Four-seater electric sofa",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY01815-3/177537384269cf21b6bf822377944576.png",
  "price": 4090,
  "max_price": 4090
  },
  {
  "id": 117304,
  "name": "footstool",
  "main_image": "https://img.gbuilderchina.com/commonimg/product/gbjj/ECO-SOF-DP-YY01817-2/177570807169cf21b302c62197095022.png",
  "price": 690,
  "max_price": 690
  }
  ],
  "spec_value": [
  {
  "type": "param",
  "name": "Product size(mm)",
  "name_cn": "\u4ea7\u54c1\u5c3a\u5bf8(mm)",
  "attr_index": "a",
  "options": [
  {
  "pid": [
  117276
  ],
  "name": "L3350*W1750*H880",
  "name_cn": "L3350*W1750*H880",
  "attr_index": "a",
  "spec": "a0"
  },
  {
  "pid": [
  117277
  ],
  "name": "L2220*W930*H880",
  "name_cn": "L2220*W930*H880",
  "attr_index": "a",
  "spec": "a1"
  },
  {
  "pid": [
  117279
  ],
  "name": "L1130*W930*H880",
  "name_cn": "L1130*W930*H880",
  "attr_index": "a",
  "spec": "a2"
  },
  {
  "pid": [
  117278
  ],
  "name": "L1730*W930*H880",
  "name_cn": "L1730*W930*H880",
  "attr_index": "a",
  "spec": "a3"
  }
  ]
  },
  {
  "type": "param",
  "name": "Material",
  "name_cn": "\u6750\u8d28",
  "attr_index": "b",
  "options": [
  {
  "pid": [
  117276,
  117277,
  117279,
  117278
  ],
  "name": "Artificial leather+sponge+Pine wood+stainless steel",
  "name_cn": "\u4eff\u771f\u76ae+\u6d77\u7ef5+\u677e\u6728+\u4e0d\u9508\u94a2",
  "attr_index": "b",
  "spec": "b0"
  }
  ]
  }
  ],
  "meta_title": "1+3+Imperial Concubine Position-Demo\u6f14\u793a\u7ad9",
  "meta_keyword": "Demo\u6f14\u793a\u7ad9-1+3+Imperial Concubine Position",
  "meta_description": "Demo\u6f14\u793a\u7ad9-1+3+Imperial Concubine Position"
  }
}''';
  return jsonDecode(json) as Map<String, dynamic>;
}