class Session {
  const Session({
    required this.isAuthenticated,
    this.accessToken,
    this.refreshToken,
  });

  final bool isAuthenticated;
  final String? accessToken;
  final String? refreshToken;
}
