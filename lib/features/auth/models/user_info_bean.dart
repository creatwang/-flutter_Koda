import 'dart:developer' as developer;

class UserInfoBase {
  num? id;
  num? accountId;
  String? name;
  String? username;
  num? companyId;
  String? avatar;
  String? telephone;
  String? description;
  num? status;
  num? type;
  String? updatedAt;
  String? createdAt;
  String? deletedAt;
  num? registerFrom;
  num? languageId;
  num? tourist;
  String? email;
  String? nickname;
  String? wechat;
  num? customerId;
  num? lastOrderTime;
  num? userMainId;
  num? shopId;
  String? token;
  // 是否是业务员
  bool? isAuthAccount;

  UserInfoBase({
    this.id,
    this.accountId,
    this.name,
    this.username,
    this.companyId,
    this.avatar,
    this.telephone,
    this.description,
    this.status,
    this.type,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
    this.registerFrom,
    this.languageId,
    this.tourist,
    this.email,
    this.nickname,
    this.wechat,
    this.customerId,
    this.lastOrderTime,
    this.userMainId,
    this.shopId,
    this.token,
    this.isAuthAccount,
  });

  /// 兼容字段类型波动（数字变字符串、Map 非强类型等），避免解析崩溃。
  factory UserInfoBase.fromJson(dynamic json) {
    try {
      final map = _coerceJsonMap(json);
      return UserInfoBase(
        id: _readNum(map['id']),
        accountId: _readNum(map['account_id']),
        name: _readStr(map['name']),
        username: _readStr(map['username']),
        companyId: _readNum(map['company_id']),
        avatar: _readStr(map['avatar']),
        telephone: _readStr(map['telephone']),
        description: _readStr(map['description']),
        status: _readNum(map['status']),
        type: _readNum(map['type']),
        updatedAt: _readStr(map['updated_at']),
        createdAt: _readStr(map['created_at']),
        deletedAt: _readStr(map['deleted_at']),
        registerFrom: _readNum(map['register_from']),
        languageId: _readNum(map['language_id']),
        tourist: _readNum(map['tourist']),
        email: _readStr(map['email']),
        nickname: _readStr(map['nickname']),
        wechat: _readStr(map['wechat']),
        customerId: _readNum(map['customer_id']),
        lastOrderTime: _readNum(map['last_order_time']),
        userMainId: _readNum(map['user_main_id']),
        shopId: _readNum(map['shop_id']),
        token: _readStr(map['token']),
        isAuthAccount: _asBool(map['is_auth_account']),
      );
    } catch (e, st) {
      developer.log(
        'UserInfoBase.fromJson fallback',
        error: e,
        stackTrace: st,
      );
      return UserInfoBase();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['account_id'] = accountId;
    data['name'] = name;
    data['username'] = username;
    data['company_id'] = companyId;
    data['avatar'] = avatar;
    data['telephone'] = telephone;
    data['description'] = description;
    data['status'] = status;
    data['type'] = type;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    data['register_from'] = registerFrom;
    data['language_id'] = languageId;
    data['tourist'] = tourist;
    data['email'] = email;
    data['nickname'] = nickname;
    data['wechat'] = wechat;
    data['customer_id'] = customerId;
    data['last_order_time'] = lastOrderTime;
    data['user_main_id'] = userMainId;
    data['shop_id'] = shopId;
    data['token'] = token;
    data['is_auth_account'] = isAuthAccount;
    return data;
  }
}

Map<String, dynamic> _coerceJsonMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    final out = <String, dynamic>{};
    raw.forEach((dynamic k, dynamic v) {
      out['$k'] = v;
    });
    return out;
  }
  return <String, dynamic>{};
}

num? _readNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  final parsed = num.tryParse(value.toString().trim());
  return parsed;
}

String? _readStr(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = '$value'.trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}
