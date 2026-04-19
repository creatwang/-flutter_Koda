/// 业务员客户列表单行（`/store/account/customer`）。
class StoreCustomerItemDto {
  const StoreCustomerItemDto({
    required this.id,
    required this.username,
    required this.telephone,
    required this.email,
    required this.createdAt,
    required this.name,
    this.avatar,
    required this.companyId,
    required this.userMainId,
  });

  factory StoreCustomerItemDto.fromJson(Map<String, dynamic> json) {
    return StoreCustomerItemDto(
      id: _readInt(json['id']) ?? 0,
      username: json['username']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      companyId: _readInt(json['company_id']) ?? 0,
      userMainId: _readInt(json['user_main_id']) ?? 0,
    );
  }

  final int id;
  final String username;
  final String telephone;
  final String email;
  final String createdAt;
  final String name;
  final String? avatar;
  final int companyId;
  final int userMainId;
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
