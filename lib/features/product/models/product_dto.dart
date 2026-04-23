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
    id = json['id'];
    categoryId = json['category_id'];
    mainImage = json['main_image'];
    subImages = (json['sub_images'] as List?)?.whereType<String>().toList(growable: false);
    name = json['name'];
    unit = json['unit'];
    viewed = json['viewed'];
    sales = json['sales'];
    price = _toDouble(json['price']);
    cnyPrice = json['cny_price'];
    categoryName = json['category_name'];
    isCollect = _toBool(json['is_collect']);
    maxPrice = _toDouble(json['max_price']);
    isHot = json['is_hot'];
    sortOrder = json['sort_order'];
    uniqid = json['uniqid'];
    formulaType = json['formula_type'];
    shopCategoryId = json['shop_category_id'];
    if (json['product_imgs'] != null) {
      productImgs = <ProductImgs>[];
      json['product_imgs'].forEach((v) {
        productImgs!.add(ProductImgs.fromJson(v));
      });
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
    url = json['url'];
    id = json['id'];
    priovity = json['priovity'];
    waterUrl = json['water_url'];
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
