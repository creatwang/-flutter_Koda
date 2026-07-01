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
  static const _storeDomain = 'store_domain';
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

  Future<void> saveUserInfoBase(UserInfoBase userInfoBase) async {
    final jsonString = jsonEncode(userInfoBase.toJson());
    await _storage.write(key: _userInfoBase, value: jsonString);
  }

  Future<UserInfoBase> mergeAndSaveUserInfoBase(
    UserInfoBase latest, {
    String? fallbackToken,
    String? fallbackDomain,
  }) async {
    final cached = await readUserInfoBase();
    final storedDomain = await getStoreDomain();
    final resolvedDomain =
        _nonEmpty(latest.domain) ??
        _nonEmpty(cached?.domain) ??
        _nonEmpty(fallbackDomain) ??
        _nonEmpty(storedDomain);
    final resolvedToken =
        _nonEmpty(latest.token) ??
        _nonEmpty(cached?.token) ??
        _nonEmpty(fallbackToken);
    final merged = UserInfoBase(
      id: latest.id ?? cached?.id,
      accountId: latest.accountId ?? cached?.accountId,
      name: latest.name ?? cached?.name,
      username: latest.username ?? cached?.username,
      companyId: latest.companyId ?? cached?.companyId,
      domain: resolvedDomain,
      avatar: latest.avatar ?? cached?.avatar,
      telephone: latest.telephone ?? cached?.telephone,
      description: latest.description ?? cached?.description,
      status: latest.status ?? cached?.status,
      type: latest.type ?? cached?.type,
      updatedAt: latest.updatedAt ?? cached?.updatedAt,
      createdAt: latest.createdAt ?? cached?.createdAt,
      deletedAt: latest.deletedAt ?? cached?.deletedAt,
      registerFrom: latest.registerFrom ?? cached?.registerFrom,
      languageId: latest.languageId ?? cached?.languageId,
      tourist: latest.tourist ?? cached?.tourist,
      email: latest.email ?? cached?.email,
      nickname: latest.nickname ?? cached?.nickname,
      wechat: latest.wechat ?? cached?.wechat,
      customerId: latest.customerId ?? cached?.customerId,
      lastOrderTime: latest.lastOrderTime ?? cached?.lastOrderTime,
      userMainId: latest.userMainId ?? cached?.userMainId,
      shopId: latest.shopId ?? cached?.shopId,
      token: resolvedToken,
      isAuthAccount: latest.isAuthAccount ?? cached?.isAuthAccount,
    );
    await saveUserInfoBase(merged);
    return merged;
  }

  Future<UserInfoBase?> readUserInfoBase() async {
    final jsonString = await _storage.read(key: _userInfoBase);
    if (jsonString == null) return null;
    return UserInfoBase.fromJson(jsonDecode(jsonString));
  }

  Future<void> saveMainUserInfo(UserInfoBase user) async {
    final jsonString = jsonEncode(user.toJson());
    await _storage.write(key: _mainUserInfo, value: jsonString);
  }

  Future<UserInfoBase?> readMainUserInfo() async {
    final jsonString = await _storage.read(key: _mainUserInfo);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return UserInfoBase.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearMainUserInfo() async {
    await _storage.delete(key: _mainUserInfo);
  }

  Future<void> saveStoreDomain(String host) async {
    await _storage.write(key: _storeDomain, value: host);
  }

  Future<String?> getStoreDomain() async {
    final value = await _storage.read(key: _storeDomain);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> deleteStoreDomain() async {
    await _storage.delete(key: _storeDomain);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userInfoBase);
    await _storage.delete(key: _mainUserInfo);
    await _storage.delete(key: _storeDomain);
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

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
