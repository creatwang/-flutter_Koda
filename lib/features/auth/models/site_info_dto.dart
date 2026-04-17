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
      productMaterialSpaceReplace: _asInt(
        json['product_material_space_replace'],
      ),
      productListExpandCategory: _asInt(json['product_list_expand_category']),
      productListPageSize: _asInt(json['product_list_page_size']),
      paramSearch: _asMapList(
        json['param_search'],
      ).map(ParamSearch.fromJson).toList(growable: false),
      productContactTips: json['product_contact_tips'],
      productPriceEmptyShow: json['product_price_empty_show'],
      pluginId: _asRawList(
        json['plugin_id'],
      ).map(_asInt).whereType<int>().toList(growable: false),
      pluginUniqid: _asRawList(
        json['plugin_uniqid'],
      ).map(_asString).whereType<String>().toList(growable: false),
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
  ParamSearch({this.rows, this.fieldName, this.groupName});

  factory ParamSearch.fromJson(Map<String, dynamic> json) {
    return ParamSearch(
      rows: _asMapList(json['rows']).map(Rows.fromJson).toList(growable: false),
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
  Rows({this.newTag, this.searchName, this.matchValues});

  factory Rows.fromJson(Map<String, dynamic> json) {
    return Rows(
      newTag: _asString(json['newTag']),
      searchName: _asString(json['searchName']),
      matchValues: _asRawList(
        json['matchValues'],
      ).map(_asString).whereType<String>().toList(growable: false),
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
