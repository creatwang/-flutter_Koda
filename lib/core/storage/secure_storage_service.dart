import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> saveTokenPair(TokenPair pair) async {
    await _storage.write(key: _accessTokenKey, value: pair.accessToken);
    await _storage.write(key: _refreshTokenKey, value: pair.refreshToken);
  }

  Future<TokenPair?> readTokenPair() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (accessToken == null || refreshToken == null) return null;
    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<String?> readAccessToken() async => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() async => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
