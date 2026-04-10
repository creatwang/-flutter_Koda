class Session {
  const Session({
    required this.isAuthenticated,
    this.companyId,
    this.token,
  });

  final bool isAuthenticated;
  final String? companyId;
  final String? token;
}
