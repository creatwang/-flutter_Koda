import 'package:groe_app_pad/features/product/models/product_item.dart';
class ProductDto {
  int? id;
  int? categoryId;
  String? mainImage;
  List<String>? subImages;
  String? name;
  String? unit;
  int? viewed;
  int? sales;
  int? price;
  int? cnyPrice;
  String? categoryName;
  bool? isCollect;
  int? maxPrice;
  int? isHot;
  int? sortOrder;
  String? uniqid;
  String? formulaType;
  int? shopCategoryId;
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
    subImages = json['sub_images'].cast<String>();
    name = json['name'];
    unit = json['unit'];
    viewed = json['viewed'];
    sales = json['sales'];
    price = json['price'];
    cnyPrice = json['cny_price'];
    categoryName = json['category_name'];
    isCollect = json['is_collect'];
    maxPrice = json['max_price'];
    isHot = json['is_hot'];
    sortOrder = json['sort_order'];
    uniqid = json['uniqid'];
    formulaType = json['formula_type'];
    shopCategoryId = json['shop_category_id'];
    if (json['product_imgs'] != null) {
      productImgs = <ProductImgs>[];
      json['product_imgs'].forEach((v) {
        productImgs!.add(new ProductImgs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['main_image'] = this.mainImage;
    data['sub_images'] = this.subImages;
    data['name'] = this.name;
    data['unit'] = this.unit;
    data['viewed'] = this.viewed;
    data['sales'] = this.sales;
    data['price'] = this.price;
    data['cny_price'] = this.cnyPrice;
    data['category_name'] = this.categoryName;
    data['is_collect'] = this.isCollect;
    data['max_price'] = this.maxPrice;
    data['is_hot'] = this.isHot;
    data['sort_order'] = this.sortOrder;
    data['uniqid'] = this.uniqid;
    data['formula_type'] = this.formulaType;
    data['shop_category_id'] = this.shopCategoryId;
    if (this.productImgs != null) {
      data['product_imgs'] = this.productImgs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductImgs {
  String? url;
  int? id;
  int? priovity;
  String? waterUrl;

  ProductImgs({this.url, this.id, this.priovity, this.waterUrl});

  ProductImgs.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'];
    priovity = json['priovity'];
    waterUrl = json['water_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['id'] = this.id;
    data['priovity'] = this.priovity;
    data['water_url'] = this.waterUrl;
    return data;
  }
}

extension ProductDtoX on ProductDto {
  ProductItem toModel() {
    return ProductItem(
     id: id!,
     categoryId: categoryId!.toString(),
     price: price!.toDouble(),
     maxPrice: maxPrice!.toString(),
     categoryName: categoryName!,
     name: name!,
     unit: unit!, isHot: isHot!.toString(), mainImage: mainImage!, isCollect: isCollect!,
    );
  }
}
