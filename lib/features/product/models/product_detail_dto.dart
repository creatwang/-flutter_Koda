int? _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? _asString(dynamic value) => value?.toString();

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}

List<String>? _asStringList(dynamic value) {
  if (value is! List) return null;
  return value.where((e) => e != null).map((e) => e.toString()).toList(growable: false);
}

class ProductDetailDto {
  int? id;
  int? categoryId;
  String? name;
  String? nameCn;
  String? unit;
  String? uniqid;
  List<dynamic>? detailImages;
  Object? parentUniqid;
  int? isHot;
  int? sortOrder;
  int? basicDeptId;
  List<ProductSub>? productSub;
  Object? shopProductDescs;
  String? mainImage;
  List<String>? subImages;
  double? price;
  double? maxPrice;
  int? cnyPrice;
  String? categoryName;
  String? formulaType;
  List<Product>? product;
  List<MatchProducts>? matchProducts;

  ProductDetailDto(
      {this.id,
        this.categoryId,
        this.name,
        this.nameCn,
        this.unit,
        this.uniqid,
        this.detailImages,
        this.parentUniqid,
        this.isHot,
        this.sortOrder,
        this.basicDeptId,
        this.productSub,
        this.shopProductDescs,
        this.mainImage,
        this.subImages,
        this.price,
        this.maxPrice,
        this.cnyPrice,
        this.categoryName,
        this.formulaType,
        this.product,
        this.matchProducts});

  ProductDetailDto.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    categoryId = _asInt(json['category_id']);
    name = _asString(json['name']);
    nameCn = _asString(json['name_cn']);
    unit = _asString(json['unit']);
    uniqid = _asString(json['uniqid']);
    if (json['detail_images'] is List) {
      detailImages = List<dynamic>.from(json['detail_images'] as List);
    }
    parentUniqid = json['parent_uniqid'];
    isHot = _asInt(json['is_hot']);
    sortOrder = _asInt(json['sort_order']);
    basicDeptId = _asInt(json['basic_dept_id']);
    final productSubList = _asMapList(json['product_sub']);
    if (productSubList.isNotEmpty) {
      productSub = productSubList.map(ProductSub.fromJson).toList(growable: false);
    }
    shopProductDescs = json['shop_product_descs'];
    mainImage = _asString(json['main_image']);
    subImages = _asStringList(json['sub_images']);
    price = _asDouble(json['price']);
    maxPrice = _asDouble(json['max_price']);
    cnyPrice = _asInt(json['cny_price']);
    categoryName = _asString(json['category_name']);
    formulaType = _asString(json['formula_type']);
    final productList = _asMapList(json['product']);
    if (productList.isNotEmpty) {
      product = productList.map(Product.fromJson).toList(growable: false);
    }
    final matchList = _asMapList(json['match_products']);
    if (matchList.isNotEmpty) {
      matchProducts = matchList.map(MatchProducts.fromJson).toList(growable: false);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['name'] = name;
    data['name_cn'] = nameCn;
    data['unit'] = unit;
    data['uniqid'] = uniqid;
    if (detailImages != null) {
      data['detail_images'] = List<dynamic>.from(detailImages!);
    }
    data['parent_uniqid'] = parentUniqid;
    data['is_hot'] = isHot;
    data['sort_order'] = sortOrder;
    data['basic_dept_id'] = basicDeptId;
    if (productSub != null) {
      data['product_sub'] = productSub!.map((v) => v.toJson()).toList();
    }
    data['shop_product_descs'] = shopProductDescs;
    data['main_image'] = mainImage;
    data['sub_images'] = subImages;
    data['price'] = price;
    data['max_price'] = maxPrice;
    data['cny_price'] = cnyPrice;
    data['category_name'] = categoryName;
    data['formula_type'] = formulaType;
    if (product != null) {
      data['product'] = product!.map((v) => v.toJson()).toList();
    }
    if (matchProducts != null) {
      data['match_products'] =
          matchProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductSub {
  int? pid;
  String? model;
  String? index;
  int? status;
  Object? image;
  int? salePriceTax;
  int? estimatedPrice;
  int? estimatedPriceTax;
  int? cnySalesPrice;
  double? exchangePrice;
  double? salesPrice;
  int? cnyEstimatedPrice;
  int? cnyEstimatedPriceTax;
  int? cnySalePriceTax;
  int? salesPriceTax;
  String? name;
  String? nameCn;
  String? sIndex;

  ProductSub(
      {this.pid,
        this.model,
        this.index,
        this.status,
        this.image,
        this.salePriceTax,
        this.estimatedPrice,
        this.estimatedPriceTax,
        this.cnySalesPrice,
        this.exchangePrice,
        this.salesPrice,
        this.cnyEstimatedPrice,
        this.cnyEstimatedPriceTax,
        this.cnySalePriceTax,
        this.salesPriceTax,
        this.name,
        this.nameCn,
        this.sIndex});

  ProductSub.fromJson(Map<String, dynamic> json) {
    pid = _asInt(json['pid']);
    model = _asString(json['model']);
    index = _asString(json['index']);
    status = _asInt(json['status']);
    image = json['image'];
    salePriceTax = _asInt(json['sale_price_tax']);
    estimatedPrice = _asInt(json['estimated_price']);
    estimatedPriceTax = _asInt(json['estimated_price_tax']);
    cnySalesPrice = _asInt(json['cny_sales_price']);
    exchangePrice = _asDouble(json['exchange_price']);
    salesPrice = _asDouble(json['sales_price']);
    cnyEstimatedPrice = _asInt(json['cny_estimated_price']);
    cnyEstimatedPriceTax = _asInt(json['cny_estimated_price_tax']);
    cnySalePriceTax = _asInt(json['cny_sale_price_tax']);
    salesPriceTax = _asInt(json['sales_price_tax']);
    name = _asString(json['name']);
    nameCn = _asString(json['name_cn']);
    sIndex = _asString(json['_index']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pid'] = pid;
    data['model'] = model;
    data['index'] = index;
    data['status'] = status;
    data['image'] = image;
    data['sale_price_tax'] = salePriceTax;
    data['estimated_price'] = estimatedPrice;
    data['estimated_price_tax'] = estimatedPriceTax;
    data['cny_sales_price'] = cnySalesPrice;
    data['exchange_price'] = exchangePrice;
    data['sales_price'] = salesPrice;
    data['cny_estimated_price'] = cnyEstimatedPrice;
    data['cny_estimated_price_tax'] = cnyEstimatedPriceTax;
    data['cny_sale_price_tax'] = cnySalePriceTax;
    data['sales_price_tax'] = salesPriceTax;
    data['name'] = name;
    data['name_cn'] = nameCn;
    data['_index'] = sIndex;
    return data;
  }
}

class Product {
  int? id;
  String? name;
  String? nameCn;
  String? uniqid;
  String? mainImage;
  List<dynamic>? detailImages;
  List<String>? subImages;
  String? categoryName;
  String? formulaType;
  int? categoryId;
  double? price;
  String? unit;
  double? maxPrice;
  int? isHot;
  Object? parentUniqid;
  int? isAttrProduct;
  int? basicDeptId;
  List<ProductParam>? productParam;
  List<ProductParamEdit>? productParamEdit;
  int? sortOrder;
  Object? shopProductDescs;
  List<GoodsDetailCard>? goodsDetailCard;
  List<SpecValue>? specValue;
  List<ProductSub>? productSub;
  bool? isCollect;
  List<dynamic>? extraParams;

  Product(
      {this.id,
        this.name,
        this.nameCn,
        this.uniqid,
        this.mainImage,
        this.detailImages,
        this.subImages,
        this.categoryName,
        this.formulaType,
        this.categoryId,
        this.price,
        this.unit,
        this.maxPrice,
        this.isHot,
        this.parentUniqid,
        this.isAttrProduct,
        this.basicDeptId,
        this.productParam,
        this.productParamEdit,
        this.sortOrder,
        this.shopProductDescs,
        this.goodsDetailCard,
        this.specValue,
        this.productSub,
        this.isCollect,
        this.extraParams});

  Product.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = _asString(json['name']);
    nameCn = _asString(json['name_cn']);
    uniqid = _asString(json['uniqid']);
    mainImage = _asString(json['main_image']);
    if (json['detail_images'] is List) {
      detailImages = List<dynamic>.from(json['detail_images'] as List);
    }
    subImages = _asStringList(json['sub_images']);
    categoryName = _asString(json['category_name']);
    formulaType = _asString(json['formula_type']);
    categoryId = _asInt(json['category_id']);
    price = _asDouble(json['price']);
    unit = _asString(json['unit']);
    maxPrice = _asDouble(json['max_price']);
    isHot = _asInt(json['is_hot']);
    parentUniqid = json['parent_uniqid'];
    isAttrProduct = _asInt(json['is_attr_product']);
    basicDeptId = _asInt(json['basic_dept_id']);
    final productParamList = _asMapList(json['product_param']);
    if (productParamList.isNotEmpty) {
      productParam = productParamList.map(ProductParam.fromJson).toList(growable: false);
    }
    final productParamEditList = _asMapList(json['product_param_edit']);
    if (productParamEditList.isNotEmpty) {
      productParamEdit = productParamEditList.map(ProductParamEdit.fromJson).toList(growable: false);
    }
    sortOrder = _asInt(json['sort_order']);
    shopProductDescs = json['shop_product_descs'];
    final detailCardList = _asMapList(json['goods_detail_card']);
    if (detailCardList.isNotEmpty) {
      goodsDetailCard = detailCardList.map(GoodsDetailCard.fromJson).toList(growable: false);
    }
    final specValueList = _asMapList(json['spec_value']);
    if (specValueList.isNotEmpty) {
      specValue = specValueList.map(SpecValue.fromJson).toList(growable: false);
    }
    final productSubList = _asMapList(json['product_sub']);
    if (productSubList.isNotEmpty) {
      productSub = productSubList.map(ProductSub.fromJson).toList(growable: false);
    }
    isCollect = json['is_collect'] == true || json['is_collect'] == 1;
    if (json['extra_params'] is List) {
      extraParams = List<dynamic>.from(json['extra_params'] as List);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['name_cn'] = nameCn;
    data['uniqid'] = uniqid;
    data['main_image'] = mainImage;
    if (detailImages != null) {
      data['detail_images'] = List<dynamic>.from(detailImages!);
    }
    data['sub_images'] = subImages;
    data['category_name'] = categoryName;
    data['formula_type'] = formulaType;
    data['category_id'] = categoryId;
    data['price'] = price;
    data['unit'] = unit;
    data['max_price'] = maxPrice;
    data['is_hot'] = isHot;
    data['parent_uniqid'] = parentUniqid;
    data['is_attr_product'] = isAttrProduct;
    data['basic_dept_id'] = basicDeptId;
    if (productParam != null) {
      data['product_param'] =
          productParam!.map((v) => v.toJson()).toList();
    }
    if (productParamEdit != null) {
      data['product_param_edit'] =
          productParamEdit!.map((v) => v.toJson()).toList();
    }
    data['sort_order'] = sortOrder;
    data['shop_product_descs'] = shopProductDescs;
    if (goodsDetailCard != null) {
      data['goods_detail_card'] =
          goodsDetailCard!.map((v) => v.toJson()).toList();
    }
    if (specValue != null) {
      data['spec_value'] = specValue!.map((v) => v.toJson()).toList();
    }
    if (productSub != null) {
      data['product_sub'] = productSub!.map((v) => v.toJson()).toList();
    }
    data['is_collect'] = isCollect;
    if (extraParams != null) {
      data['extra_params'] = List<dynamic>.from(extraParams!);
    }
    return data;
  }
}

class ProductParam {
  String? nameEn;
  String? nameCn;
  String? valueEn;
  String? valueCn;
  int? pid;
  String? name;
  String? value;

  ProductParam(
      {this.nameEn,
        this.nameCn,
        this.valueEn,
        this.valueCn,
        this.pid,
        this.name,
        this.value});

  ProductParam.fromJson(Map<String, dynamic> json) {
    nameEn = _asString(json['name_en']);
    nameCn = _asString(json['name_cn']);
    valueEn = _asString(json['value_en']);
    valueCn = _asString(json['value_cn']);
    pid = _asInt(json['pid']);
    name = _asString(json['name']);
    value = _asString(json['value']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name_en'] = nameEn;
    data['name_cn'] = nameCn;
    data['value_en'] = valueEn;
    data['value_cn'] = valueCn;
    data['pid'] = pid;
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class ProductParamEdit extends ProductParam {
  ProductParamEdit({
    super.nameEn,
    super.nameCn,
    super.valueEn,
    super.valueCn,
    super.pid,
    super.name,
    super.value,
  });

  ProductParamEdit.fromJson(super.json) : super.fromJson();
}

class GoodsDetailCard {
  String? title;
  String? type;
  List<Content>? content;

  GoodsDetailCard({this.title, this.type, this.content});

  GoodsDetailCard.fromJson(Map<String, dynamic> json) {
    title = _asString(json['title']);
    type = _asString(json['type']);
    final contentList = _asMapList(json['content']);
    if (contentList.isNotEmpty) {
      content = contentList.map(Content.fromJson).toList(growable: false);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['type'] = type;
    if (content != null) {
      data['content'] = content!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Content {
  String? name;
  String? value;

  Content({this.name, this.value});

  Content.fromJson(Map<String, dynamic> json) {
    name = _asString(json['name']);
    value = _asString(json['value']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class SpecValue {
  String? type;
  String? name;
  String? nameCn;
  String? attrIndex;
  List<Options>? options;

  SpecValue({this.type, this.name, this.nameCn, this.attrIndex, this.options});

  SpecValue.fromJson(Map<String, dynamic> json) {
    type = _asString(json['type']);
    name = _asString(json['name']);
    nameCn = _asString(json['name_cn']);
    attrIndex = _asString(json['attr_index']);
    final optionList = _asMapList(json['options']);
    if (optionList.isNotEmpty) {
      options = optionList.map(Options.fromJson).toList(growable: false);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['name'] = name;
    data['name_cn'] = nameCn;
    data['attr_index'] = attrIndex;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  List<int>? pid;
  String? name;
  String? nameCn;
  String? attrIndex;
  String? spec;

  Options({this.pid, this.name, this.nameCn, this.attrIndex, this.spec});

  Options.fromJson(Map<String, dynamic> json) {
    if (json['pid'] is List) {
      pid = (json['pid'] as List)
          .map(_asInt)
          .whereType<int>()
          .toList(growable: false);
    }
    name = _asString(json['name']);
    nameCn = _asString(json['name_cn']);
    attrIndex = _asString(json['attr_index']);
    spec = _asString(json['spec']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pid'] = pid;
    data['name'] = name;
    data['name_cn'] = nameCn;
    data['attr_index'] = attrIndex;
    data['spec'] = spec;
    return data;
  }
}

class MatchProducts {
  int? id;
  String? name;
  String? mainImage;
  double? price;
  double? maxPrice;

  MatchProducts(
      {this.id, this.name, this.mainImage, this.price, this.maxPrice});

  MatchProducts.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = _asString(json['name']);
    mainImage = _asString(json['main_image']);
    price = _asDouble(json['price']);
    maxPrice = _asDouble(json['max_price']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['main_image'] = mainImage;
    data['price'] = price;
    data['max_price'] = maxPrice;
    return data;
  }
}
