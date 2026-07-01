class TokenPair {
  const TokenPair({
    this.storeHost,
    this.token,
    this.accessToken,
    this.refreshToken,
  }) : resolvedAccessToken = accessToken ?? token ?? '',
       resolvedRefreshToken = refreshToken ?? '';

  final String? storeHost;
  final String? token;
  final String? accessToken;
  final String? refreshToken;

  final String resolvedAccessToken;
  final String resolvedRefreshToken;
}
