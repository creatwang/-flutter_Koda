import 'package:george_pick_mate/features/product/models/product_item.dart';
class ProductDto {
  int? id;
  num? categoryId;
  String? mainImage;
  List<String>? subImages;
  String? name;
  String? unit;
  num? viewed;
  num? sales;
  double? price;
  num? cnyPrice;
  String? categoryName;
  bool? isCollect;
  double? maxPrice;
  num? isHot;
  num? sortOrder;
  String? uniqid;
  String? formulaType;
  num? shopCategoryId;
  List<ProductImgs>? productImgs;

  ProductDto(
      {this.id,
        this.categoryId,
        this.mainImage,
        this.subImages,
        this.name,
        this.unit,
        this.viewed,
        this.sales,
        this.price,
        this.cnyPrice,
        this.categoryName,
        this.isCollect,
        this.maxPrice,
        this.isHot,
        this.sortOrder,
        this.uniqid,
        this.formulaType,
        this.shopCategoryId,
        this.productImgs});

  ProductDto.fromJson(Map<String, dynamic> json) {
    id = _toIntOrNull(json['id']);
    categoryId = _toNum(json['category_id']);
    mainImage = _toStringOrNull(json['main_image']);
    subImages = _toStringList(json['sub_images']);
    name = _toStringOrNull(json['name']);
    unit = _toStringOrNull(json['unit']);
    viewed = _toNum(json['viewed']);
    sales = _toNum(json['sales']);
    price = _toDouble(json['price']);
    cnyPrice = _toNum(json['cny_price']);
    categoryName = _toStringOrNull(json['category_name']);
    isCollect = _toBool(json['is_collect']);
    maxPrice = _toDouble(json['max_price']);
    isHot = _toNum(json['is_hot']);
    sortOrder = _toNum(json['sort_order']);
    uniqid = _toStringOrNull(json['uniqid']);
    formulaType = _toStringOrNull(json['formula_type']);
    shopCategoryId = _toNum(json['shop_category_id']);
    final rawProductImgs = json['product_imgs'];
    if (rawProductImgs is List) {
      productImgs = rawProductImgs
          .whereType<Map>()
          .map((e) => ProductImgs.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['main_image'] = mainImage;
    data['sub_images'] = subImages;
    data['name'] = name;
    data['unit'] = unit;
    data['viewed'] = viewed;
    data['sales'] = sales;
    data['price'] = price;
    data['cny_price'] = cnyPrice;
    data['category_name'] = categoryName;
    data['is_collect'] = isCollect;
    data['max_price'] = maxPrice;
    data['is_hot'] = isHot;
    data['sort_order'] = sortOrder;
    data['uniqid'] = uniqid;
    data['formula_type'] = formulaType;
    data['shop_category_id'] = shopCategoryId;
    if (productImgs != null) {
      data['product_imgs'] = productImgs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductImgs {
  String? url;
  num? id;
  num? priovity;
  String? waterUrl;

  ProductImgs({this.url, this.id, this.priovity, this.waterUrl});

  ProductImgs.fromJson(Map<String, dynamic> json) {
    url = _toStringOrNull(json['url']);
    id = _toNum(json['id']);
    priovity = _toNum(json['priovity']);
    waterUrl = _toStringOrNull(json['water_url']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['id'] = id;
    data['priovity'] = priovity;
    data['water_url'] = waterUrl;
    return data;
  }
}

extension ProductDtoX on ProductDto {
  ProductItem toModel() {
    return ProductItem(
      id: _toInt(id),
      categoryId: categoryId ?? 0,
      price: price ?? 0,
      maxPrice: maxPrice ?? 0,
      categoryName: categoryName ?? '',
      name: name ?? '',
      unit: unit ?? '',
      isHot: isHot?.toString() ?? '0',
      mainImage: mainImage ?? '',
      isCollect: isCollect ?? false,
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

num? _toNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

List<String>? _toStringList(dynamic value) {
  if (value is! List) return null;
  return value
      .where((element) => element != null)
      .map((element) => element.toString())
      .toList(growable: false);
}

bool? _toBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _toIntOrNull(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
