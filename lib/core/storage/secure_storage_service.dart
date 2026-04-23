import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:george_pick_mate/core/storage/token_pair.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userInfoBase = 'user_info_base';
  static const _mainUserInfo = 'main_user_info';
  static const _tokenMap = 'token_map';
  static const _companyId = 'company_id';
  static const _rememberedLoginUsername = 'remembered_login_username';
  static const _rememberedLoginPassword = 'remembered_login_password';

  final FlutterSecureStorage _storage;

  Future<void> saveTokenPair(TokenPair pair) async {
    await _storage.write(key: _accessTokenKey, value: pair.resolvedAccessToken);
    if (pair.resolvedRefreshToken.isNotEmpty) {
      await _storage.write(
        key: _refreshTokenKey,
        value: pair.resolvedRefreshToken,
      );
    }
  }

  Future<TokenPair?> readTokenPair() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) return null;
    final refreshToken = await _storage.read(key: _refreshTokenKey) ?? '';
    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<String?> readAccessToken() async =>
      _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() async =>
      _storage.read(key: _refreshTokenKey);

  /// 保存用户信息。
  Future<void> saveUserInfoBase(UserInfoBase userInfoBase) async {
    String jsonString = jsonEncode(userInfoBase.toJson());
    await _storage.write(key: _userInfoBase, value: jsonString);
  }

  /// 获取用户信息。
  Future<UserInfoBase?> readUserInfoBase() async {
    String? jsonString = await _storage.read(key: _userInfoBase);
    if (jsonString == null) return null;
    final userInfoBase = UserInfoBase.fromJson(jsonDecode(jsonString));
    return userInfoBase;
  }

  /// 业务员「代客登录」前缓存的主账号信息，供 [Switch Account] 切回。
  Future<void> saveMainUserInfo(UserInfoBase user) async {
    final jsonString = jsonEncode(user.toJson());
    await _storage.write(key: _mainUserInfo, value: jsonString);
  }

  /// 读取主账号缓存；无则返回 `null`。
  Future<UserInfoBase?> readMainUserInfo() async {
    final jsonString = await _storage.read(key: _mainUserInfo);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return UserInfoBase.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearMainUserInfo() async {
    await _storage.delete(key: _mainUserInfo);
  }

  /// 保存 token。
  Future<void> saveTokenMap(int companyId, String token) async {
    final previousMap = await _readTokenMap();
    previousMap[companyId.toString()] = token;
    String jsonString = jsonEncode(previousMap);
    await _storage.write(key: _tokenMap, value: jsonString);
  }

  /// 根据站点 id 获取 token。
  Future<String?> getTokenByCompanyId(int companyId) async {
    final tokenMap = await _readTokenMap();
    final key = companyId.toString();
    if (!tokenMap.containsKey(key)) return null;
    return tokenMap[key]?.toString();
  }

  /// 保存站点 id。
  Future<void> saveCompanyId(int companyId) async {
    await _storage.write(key: _companyId, value: companyId.toString());
  }

  /// 获取站点 id。
  Future<int?> getCompanyId() async {
    String? companyId = await _storage.read(key: _companyId);
    if (companyId == null || companyId.isEmpty) return null;
    return int.tryParse(companyId);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userInfoBase);
    await _storage.delete(key: _mainUserInfo);
    await _storage.delete(key: _tokenMap);
    await _storage.delete(key: _companyId);
    // 登出不清「记住的登录表单」，便于再次登录。
  }

  Future<void> saveRememberedLoginUsername(String username) async {
    await _storage.write(key: _rememberedLoginUsername, value: username);
  }

  Future<String?> readRememberedLoginUsername() async =>
      _storage.read(key: _rememberedLoginUsername);

  Future<void> saveRememberedLoginPassword(String password) async {
    await _storage.write(key: _rememberedLoginPassword, value: password);
  }

  Future<String?> readRememberedLoginPassword() async =>
      _storage.read(key: _rememberedLoginPassword);

  Future<void> deleteRememberedLoginPassword() async {
    await _storage.delete(key: _rememberedLoginPassword);
  }

  Future<Map<String, dynamic>> _readTokenMap() async {
    String? jsonString = await _storage.read(key: _tokenMap);
    if (jsonString == null || jsonString.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return <String, dynamic>{};
      }
      return decoded;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
