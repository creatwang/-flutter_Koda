class SiteInfoDto {
  SiteInfoDto({
    this.shopRegisterOn,
    this.shopPrivacyPolicy,
    this.shopUserPolicy,
    this.productAddcartSpace,
    this.productPriceEmptyCanOrder,
    this.logo,
    this.icon,
    this.backendLogo,
    this.statisticCode,
    this.themeId,
    this.productListOpenNewWindow,
    this.productDetailOpenNewWindow,
    this.productDefaultSort,
    this.productSearchOptions,
    this.productMaterialSpaceReplace,
    this.productListExpandCategory,
    this.productListPageSize,
    this.paramSearch,
    this.productContactTips,
    this.productPriceEmptyShow,
    this.pluginId,
    this.pluginUniqid,
    this.heatmapList,
    this.checkCode,
  });

  factory SiteInfoDto.fromDio(dynamic data) {
    final json = _asMap(data) ?? <String, dynamic>{};
    if (json.containsKey('data')) {
      final wrapped = _asMap(json['data']);
      if (wrapped != null) return SiteInfoDto.fromJson(wrapped);
    }
    return SiteInfoDto.fromJson(json);
  }

  factory SiteInfoDto.fromJson(Map<String, dynamic> json) {
    return SiteInfoDto(
      shopRegisterOn: _asInt(json['shop_register_on']),
      shopPrivacyPolicy: json['shop_privacy_policy'],
      shopUserPolicy: json['shop_user_policy'],
      productAddcartSpace: _asInt(json['product_addcart_space']),
      productPriceEmptyCanOrder: _asInt(json['product_price_empty_can_order']),
      logo: _asString(json['logo']),
      icon: _asString(json['icon']),
      backendLogo: _asString(json['backend_logo']),
      statisticCode: json['statistic_code'],
      themeId: _asInt(json['theme_id']),
      productListOpenNewWindow: _asInt(json['product_list_open_new_window']),
      productDetailOpenNewWindow: _asInt(
        json['product_detail_open_new_window'],
      ),
      productDefaultSort: _asInt(json['product_default_sort']),
      productSearchOptions: json['product_search_options'],
      productMaterialSpaceReplace: _asInt(json['product_material_space_replace']),
      productListExpandCategory: _asInt(json['product_list_expand_category']),
      productListPageSize: _asInt(json['product_list_page_size']),
      paramSearch: _asMapList(json['param_search'])
          .map(ParamSearch.fromJson)
          .toList(growable: false),
      productContactTips: json['product_contact_tips'],
      productPriceEmptyShow: json['product_price_empty_show'],
      pluginId: _asRawList(json['plugin_id'])
          .map(_asInt)
          .whereType<int>()
          .toList(growable: false),
      pluginUniqid: _asRawList(json['plugin_uniqid'])
          .map(_asString)
          .whereType<String>()
          .toList(growable: false),
      heatmapList: _asRawList(json['heatmapList']),
      checkCode: _asString(json['check_code']),
    );
  }

  int? shopRegisterOn;
  dynamic shopPrivacyPolicy;
  dynamic shopUserPolicy;
  int? productAddcartSpace;
  int? productPriceEmptyCanOrder;
  String? logo;
  String? icon;
  String? backendLogo;
  dynamic statisticCode;
  int? themeId;
  int? productListOpenNewWindow;
  int? productDetailOpenNewWindow;
  int? productDefaultSort;
  dynamic productSearchOptions;
  int? productMaterialSpaceReplace;
  int? productListExpandCategory;
  int? productListPageSize;
  List<ParamSearch>? paramSearch;
  dynamic productContactTips;
  dynamic productPriceEmptyShow;
  List<int>? pluginId;
  List<String>? pluginUniqid;
  List<dynamic>? heatmapList;
  String? checkCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'shop_register_on': shopRegisterOn,
      'shop_privacy_policy': shopPrivacyPolicy,
      'shop_user_policy': shopUserPolicy,
      'product_addcart_space': productAddcartSpace,
      'product_price_empty_can_order': productPriceEmptyCanOrder,
      'logo': logo,
      'icon': icon,
      'backend_logo': backendLogo,
      'statistic_code': statisticCode,
      'theme_id': themeId,
      'product_list_open_new_window': productListOpenNewWindow,
      'product_detail_open_new_window': productDetailOpenNewWindow,
      'product_default_sort': productDefaultSort,
      'product_search_options': productSearchOptions,
      'product_material_space_replace': productMaterialSpaceReplace,
      'product_list_expand_category': productListExpandCategory,
      'product_list_page_size': productListPageSize,
      'param_search': paramSearch
          ?.map((v) => v.toJson())
          .toList(growable: false),
      'product_contact_tips': productContactTips,
      'product_price_empty_show': productPriceEmptyShow,
      'plugin_id': pluginId,
      'plugin_uniqid': pluginUniqid,
      'heatmapList': heatmapList,
      'check_code': checkCode,
    };
  }
}

class ParamSearch {
  ParamSearch({
    this.rows,
    this.fieldName,
    this.groupName,
  });

  factory ParamSearch.fromJson(Map<String, dynamic> json) {
    return ParamSearch(
      rows: _asMapList(json['rows'])
          .map(Rows.fromJson)
          .toList(growable: false),
      fieldName: _asString(json['fieldName']),
      groupName: _asString(json['groupName']),
    );
  }

  List<Rows>? rows;
  String? fieldName;
  String? groupName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rows': rows?.map((v) => v.toJson()).toList(growable: false),
      'fieldName': fieldName,
      'groupName': groupName,
    };
  }
}

class Rows {
  Rows({
    this.newTag,
    this.searchName,
    this.matchValues,
  });

  factory Rows.fromJson(Map<String, dynamic> json) {
    return Rows(
      newTag: _asString(json['newTag']),
      searchName: _asString(json['searchName']),
      matchValues: _asRawList(json['matchValues'])
          .map(_asString)
          .whereType<String>()
          .toList(growable: false),
    );
  }

  String? newTag;
  String? searchName;
  List<String>? matchValues;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'newTag': newTag,
      'searchName': searchName,
      'matchValues': matchValues,
    };
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry('$k', v));
  return null;
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return value
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

List<dynamic> _asRawList(dynamic value) {
  if (value is! Iterable) return const <dynamic>[];
  return List<dynamic>.from(value);
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final normalized = '$value'.trim();
  if (normalized.isEmpty || normalized == 'null') return null;
  return normalized;
}
class SiteInfoDto {
  int? shopRegisterOn;
  Null? shopPrivacyPolicy;
  Null? shopUserPolicy;
  int? productAddcartSpace;
  int? productPriceEmptyCanOrder;
  String? logo;
  String? icon;
  String? backendLogo;
  Null? statisticCode;
  int? themeId;
  int? productListOpenNewWindow;
  int? productDetailOpenNewWindow;
  int? productDefaultSort;
  Null? productSearchOptions;
  int? productMaterialSpaceReplace;
  int? productListExpandCategory;
  int? productListPageSize;
  List<ParamSearch>? paramSearch;
  Null? productContactTips;
  Null? productPriceEmptyShow;
  List<int>? pluginId;
  List<String>? pluginUniqid;
  List<Null>? heatmapList;
  String? checkCode;

  SiteInfoDto(
      {this.shopRegisterOn,
      this.shopPrivacyPolicy,
      this.shopUserPolicy,
      this.productAddcartSpace,
      this.productPriceEmptyCanOrder,
      this.logo,
      this.icon,
      this.backendLogo,
      this.statisticCode,
      this.themeId,
      this.productListOpenNewWindow,
      this.productDetailOpenNewWindow,
      this.productDefaultSort,
      this.productSearchOptions,
      this.productMaterialSpaceReplace,
      this.productListExpandCategory,
      this.productListPageSize,
      this.paramSearch,
      this.productContactTips,
      this.productPriceEmptyShow,
      this.pluginId,
      this.pluginUniqid,
      this.heatmapList,
      this.checkCode});

  SiteInfoDto.fromJson(Map<String, dynamic> json) {
    shopRegisterOn = json['shop_register_on'];
    shopPrivacyPolicy = json['shop_privacy_policy'];
    shopUserPolicy = json['shop_user_policy'];
    productAddcartSpace = json['product_addcart_space'];
    productPriceEmptyCanOrder = json['product_price_empty_can_order'];
    logo = json['logo'];
    icon = json['icon'];
    backendLogo = json['backend_logo'];
    statisticCode = json['statistic_code'];
    themeId = json['theme_id'];
    productListOpenNewWindow = json['product_list_open_new_window'];
    productDetailOpenNewWindow = json['product_detail_open_new_window'];
    productDefaultSort = json['product_default_sort'];
    productSearchOptions = json['product_search_options'];
    productMaterialSpaceReplace = json['product_material_space_replace'];
    productListExpandCategory = json['product_list_expand_category'];
    productListPageSize = json['product_list_page_size'];
    if (json['param_search'] != null) {
      paramSearch = <ParamSearch>[];
      json['param_search'].forEach((v) {
        paramSearch!.add(new ParamSearch.fromJson(v));
      });
    }
    productContactTips = json['product_contact_tips'];
    productPriceEmptyShow = json['product_price_empty_show'];
    pluginId = json['plugin_id'].cast<int>();
    pluginUniqid = json['plugin_uniqid'].cast<String>();
    if (json['heatmapList'] != null) {
      heatmapList = <Null>[];
      json['heatmapList'].forEach((v) {
        heatmapList!.add(new Null.fromJson(v));
      });
    }
    checkCode = json['check_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shop_register_on'] = this.shopRegisterOn;
    data['shop_privacy_policy'] = this.shopPrivacyPolicy;
    data['shop_user_policy'] = this.shopUserPolicy;
    data['product_addcart_space'] = this.productAddcartSpace;
    data['product_price_empty_can_order'] = this.productPriceEmptyCanOrder;
    data['logo'] = this.logo;
    data['icon'] = this.icon;
    data['backend_logo'] = this.backendLogo;
    data['statistic_code'] = this.statisticCode;
    data['theme_id'] = this.themeId;
    data['product_list_open_new_window'] = this.productListOpenNewWindow;
    data['product_detail_open_new_window'] = this.productDetailOpenNewWindow;
    data['product_default_sort'] = this.productDefaultSort;
    data['product_search_options'] = this.productSearchOptions;
    data['product_material_space_replace'] = this.productMaterialSpaceReplace;
    data['product_list_expand_category'] = this.productListExpandCategory;
    data['product_list_page_size'] = this.productListPageSize;
    if (this.paramSearch != null) {
      data['param_search'] = this.paramSearch!.map((v) => v.toJson()).toList();
    }
    data['product_contact_tips'] = this.productContactTips;
    data['product_price_empty_show'] = this.productPriceEmptyShow;
    data['plugin_id'] = this.pluginId;
    data['plugin_uniqid'] = this.pluginUniqid;
    if (this.heatmapList != null) {
      data['heatmapList'] = this.heatmapList!.map((v) => v.toJson()).toList();
    }
    data['check_code'] = this.checkCode;
    return data;
  }
}

class ParamSearch {
  List<Rows>? rows;
  String? fieldName;
  String? groupName;

  ParamSearch({this.rows, this.fieldName, this.groupName});

  ParamSearch.fromJson(Map<String, dynamic> json) {
    if (json['rows'] != null) {
      rows = <Rows>[];
      json['rows'].forEach((v) {
        rows!.add(new Rows.fromJson(v));
      });
    }
    fieldName = json['fieldName'];
    groupName = json['groupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rows != null) {
      data['rows'] = this.rows!.map((v) => v.toJson()).toList();
    }
    data['fieldName'] = this.fieldName;
    data['groupName'] = this.groupName;
    return data;
  }
}

class Rows {
  String? newTag;
  String? searchName;
  List<String>? matchValues;

  Rows({this.newTag, this.searchName, this.matchValues});

  Rows.fromJson(Map<String, dynamic> json) {
    newTag = json['newTag'];
    searchName = json['searchName'];
    matchValues = json['matchValues'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['newTag'] = this.newTag;
    data['searchName'] = this.searchName;
    data['matchValues'] = this.matchValues;
    return data;
  }
}
