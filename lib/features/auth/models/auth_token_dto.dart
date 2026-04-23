import 'package:george_pick_mate/core/storage/token_pair.dart';

class AuthTokenDto {
  const AuthTokenDto({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenDto(
      accessToken: json['accessToken']?.toString() ??
          json['token']?.toString() ??
          'demo-access-token',
      refreshToken: json['refreshToken']?.toString() ?? 'demo-refresh-token',
    );
  }
}

extension AuthTokenDtoX on AuthTokenDto {
  TokenPair toPair() {
    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }
}
