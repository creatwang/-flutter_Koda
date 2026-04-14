class Session {
  const Session({
    required this.isAuthenticated,
    this.companyId,
    this.token,
  });

  final bool isAuthenticated;
  final int? companyId;
  final String? token;
}
