
// 业务s插件keys
class BusinessPluginKeys {
  static const String exportQuotation = 'export_quotation';
  static const String productAlbum = 'product_album';
  static const String productCompare = 'product_compare';
  static const String pageDiy = 'page_diy';
  static const String pictureTo3d = 'picture_to_3d';
  static const String im = 'im';
  static const String productComment = 'product_comment';

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

bool hasBusinessPlugin({
  required Iterable<String>? pluginUniqids,
  required String pluginKey,
}) {
  if (pluginUniqids == null || pluginUniqids.isEmpty) return false;
  final normalized = pluginKey.trim();
  if (normalized.isEmpty) return false;
  return pluginUniqids.contains(normalized);
}
