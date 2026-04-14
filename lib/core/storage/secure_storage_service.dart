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

  /// 保存 token。
  Future<void> saveTokenMap(int companyId, String token) async {
    String jsonString = jsonEncode({companyId.toString(): token});
    await _storage.write(key: _tokenMap, value: jsonString);
  }

  /// 根据站点 id 获取 token。
  Future<String?> getTokenByCompanyId(int companyId) async {
    String? jsonString = await _storage.read(key: _tokenMap);
    if (jsonString == null) return null;
    Map<String, dynamic> tokenMap = jsonDecode(jsonString);
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
    await _storage.delete(key: _tokenMap);
    await _storage.delete(key: _companyId);
  }
}
