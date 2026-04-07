import 'package:groe_app_pad/core/storage/token_pair.dart';

class AuthTokenDto {
  const AuthTokenDto({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenDto(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }
}

extension AuthTokenDtoX on AuthTokenDto {
  TokenPair toPair() {
    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }
}
