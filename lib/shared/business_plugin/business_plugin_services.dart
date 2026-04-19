/// 业务插件 key 集合（与站点 `plugin_uniqid` 对齐的语义化常量）。
class BusinessPluginKeys {
  BusinessPluginKeys._();

  /// 导出报价
  static const String exportQuotation = 'export_quotation';

  /// 商品相册
  static const String productAlbum = 'product_album';

  /// 商品对比
  static const String productCompare = 'product_compare';

  /// 页面 DIY
  static const String pageDiy = 'page_diy';

  /// 图片转 3D
  static const String pictureTo3d = 'picture_to_3d';

  /// 即时通讯
  static const String im = 'im';

  /// 商品评论
  static const String productComment = 'product_comment';

  /// 全部已知 key（用于校验或遍历）。
  static const Set<String> all = <String>{
    exportQuotation,
    productAlbum,
    productCompare,
    pageDiy,
    pictureTo3d,
    im,
    productComment,
  };
}

/// 判断站点插件列表中是否包含给定 [pluginKey]。
///
/// [pluginUniqids]：站点返回的插件 id 列表，可为 `null`。
/// [pluginKey]：与 [BusinessPluginKeys] 中常量一致的字符串。
bool hasBusinessPlugin({
  required Iterable<String>? pluginUniqids,
  required String pluginKey,
}) {
  if (pluginUniqids == null || pluginUniqids.isEmpty) return false;
  final normalized = pluginKey.trim();
  if (normalized.isEmpty) return false;
  return pluginUniqids.contains(normalized);
}
