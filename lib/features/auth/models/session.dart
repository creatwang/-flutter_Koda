class Session {
  const Session({
    this.isAuthenticated = false,
    this.storeHost,
    this.token,
  });

  final bool isAuthenticated;
  final String? storeHost;
  final String? token;
}
