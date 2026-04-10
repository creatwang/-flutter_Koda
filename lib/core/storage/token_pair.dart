class TokenPair {
  const TokenPair({
    this.companyId,
    this.token,
    this.accessToken,
    this.refreshToken,
  }) : resolvedAccessToken = accessToken ?? token ?? '',
       resolvedRefreshToken = refreshToken ?? '';

  final String? companyId;
  final String? token;
  final String? accessToken;
  final String? refreshToken;

  final String resolvedAccessToken;
  final String resolvedRefreshToken;
}
