import 'dart:convert';

import 'package:george_pick_mate/features/cart/models/cart_list_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _cartStorageKey = 'cart_lists_by_site_v1';

/// 从本地读取上次缓存的购物车（站点分组结构）。
Future<List<CartListDto>> readCartListFromLocal() async {
  final preferences = await SharedPreferences.getInstance();
  final rawJson = preferences.getString(_cartStorageKey);
  if (rawJson == null || rawJson.isEmpty) {
    return const <CartListDto>[];
  }

  try {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      return const <CartListDto>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => CartListDto.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  } catch (_) {
    return const <CartListDto>[];
  }
}

/// 将当前购物车列表写入本地（用于离线展示或失败回退）。
Future<void> saveCartListToLocal({required List<CartListDto> items}) async {
  final preferences = await SharedPreferences.getInstance();
  final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
  await preferences.setString(_cartStorageKey, encoded);
}

/// 清除本地购物车缓存（如登出时）。
Future<void> clearCartListFromLocal() async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(_cartStorageKey);
}
