class UserProfileInfoDto {
  const UserProfileInfoDto({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.telephone,
    required this.description,
    required this.tourist,
    required this.isAuthAccount,
  });

  final int? id;
  final String name;
  final String? username;
  final String? avatar;
  final String? telephone;
  final String? description;
  final int? tourist;
  final bool isAuthAccount;

  factory UserProfileInfoDto.fromJson(Map<String, dynamic> json) {
    return UserProfileInfoDto(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      username: json['username']?.toString(),
      avatar: json['avatar']?.toString(),
      telephone: json['telephone']?.toString(),
      description: json['description']?.toString(),
      tourist: _asInt(json['tourist']),
      isAuthAccount:
          json['is_auth_account'] == true || json['is_auth_account'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'telephone': telephone,
      'description': description,
      'tourist': tourist,
      'is_auth_account': isAuthAccount,
    };
  }
}

int? _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
