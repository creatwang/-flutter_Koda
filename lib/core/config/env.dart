class Env {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://fakestoreapi.com',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
