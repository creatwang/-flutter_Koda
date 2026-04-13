import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userInfoBase = 'user_info_base';
  static const _tokenMap = 'token_map';
  static const _companyId = 'company_id';

  final FlutterSecureStorage _storage;

  Future<void> saveTokenPair(TokenPair pair) async {
    await _storage.write(key: _accessTokenKey, value: pair.resolvedAccessToken);
    if (pair.resolvedRefreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: pair.resolvedRefreshToken);
    }
  }

  Future<TokenPair?> readTokenPair() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) return null;
    final refreshToken = await _storage.read(key: _refreshTokenKey) ?? '';
    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<String?> readAccessToken() async => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() async => _storage.read(key: _refreshTokenKey);
  /**
   * @Description保存用户信息
   * @date 2026/04/10 19:03:50
   */
  Future<void> saveUserInfoBase(UserInfoBase userInfoBase) async {
    String jsonString = jsonEncode(userInfoBase.toJson());
    await _storage.write(key: _userInfoBase, value: jsonString);
  }

  /**
   * @Description 获取用户信息
   * @date 2026/04/10 19:03:16
   */
  Future<UserInfoBase?> readUserInfoBase() async {
    String? jsonString = await _storage.read(key: _userInfoBase);
    if (jsonString == null) return null;
    final userInfoBase = UserInfoBase.fromJson(jsonDecode(jsonString));
    return userInfoBase;
  }

  /**
   * @Description 保存token
   * @date 2026/04/10 19:03:40
   */
  Future<void> saveTokenMap(String companyId, String token) async {
    String jsonString = jsonEncode({companyId: token});
    await _storage.write(key: _tokenMap, value: jsonString);
  }

  /**
   * @Description 根据站点id获取token
   * @date 2026/04/10 19:03:16
   */
  Future<String?> getTokenByCompanyId(String companyId) async {
    String? jsonString = await _storage.read(key: _tokenMap);
    if (jsonString == null) return null;
    Map<String, dynamic> tokenMap = jsonDecode(jsonString);
    if (!tokenMap.containsKey(companyId)) return null;
    return tokenMap[companyId];
  }

  /**
   * @Description 保存站点Id
   * @date 2026/04/10 19:03:40
   */
  Future<void> saveCompanyId(String companyId) async {
    await _storage.write(key: _companyId, value: companyId);
  }

  /**
   * @Description 获取站点Id
   * @date 2026/04/10 19:03:16
   */
  Future<String> getCompanyId() async {
    String? companyId = await _storage.read(key: _companyId);
    if (companyId == null || companyId.isEmpty) {
      return '0';
    }
    return companyId;
  }



  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userInfoBase);
    await _storage.delete(key: _tokenMap);
    await _storage.delete(key: _companyId);
  }
}
