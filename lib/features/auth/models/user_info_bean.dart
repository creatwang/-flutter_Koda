import 'dart:developer' as developer;

class UserInfoBase {
  num? id;
  num? accountId;
  String? name;
  String? username;
  num? companyId;
  String? domain;
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

  /// 是否具备可展示的身份字段（id / name / username 任一有效）。
  bool get hasProfileIdentity =>
      (id != null && id != 0) ||
      (accountId != null && accountId != 0) ||
      (name?.trim().isNotEmpty == true) ||
      (username?.trim().isNotEmpty == true);

  /// 侧栏与表单优先展示的称呼。
  String get displayName {
    for (final candidate in <String?>[name, username, nickname, email]) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  /// 侧栏 UID；优先 [id]，否则回退 [accountId]。
  int? get profileUserId {
    final primary = id?.toInt();
    if (primary != null && primary != 0) return primary;
    final fallback = accountId?.toInt();
    if (fallback != null && fallback != 0) return fallback;
    return null;
  }

  UserInfoBase({
    this.id,
    this.accountId,
    this.name,
    this.username,
    this.companyId,
    this.domain,
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

  /// 从接口外层 envelope（`code/result/data/user`）解析用户资料。
  factory UserInfoBase.fromApiEnvelope(dynamic data) {
    final payload = resolveUserInfoPayload(data);
    if (payload == null) return UserInfoBase();
    return UserInfoBase.fromJson(payload);
  }

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
        domain: _readStr(map['domain']),
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
    data['domain'] = domain;
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

Map<String, dynamic>? resolveUserInfoPayload(dynamic data) {
  final root = _coerceJsonMap(data);
  if (root.isEmpty) return null;

  final candidates = <Map<String, dynamic>>[
    _coerceJsonMap(root['result']),
    _coerceJsonMap(root['data']),
    root,
  ];

  for (final candidate in candidates) {
    if (candidate.isEmpty) continue;
    final nestedUser = _coerceJsonMap(candidate['user']);
    if (nestedUser.isNotEmpty) return nestedUser;
    if (candidate.containsKey('id') ||
        candidate.containsKey('account_id') ||
        candidate.containsKey('name') ||
        candidate.containsKey('username') ||
        candidate.containsKey('token')) {
      return candidate;
    }
  }

  final result = _coerceJsonMap(root['result']);
  return result.isNotEmpty ? result : root;
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
