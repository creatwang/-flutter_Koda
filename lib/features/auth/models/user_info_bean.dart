class UserInfoBase {
  num? id;
  num? accountId;
  String? name;
  String? username;
  num? companyId;
  String? avatar;
  Null telephone;
  Null description;
  num? status;
  num? type;
  String? updatedAt;
  String? createdAt;
  Null deletedAt;
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

  UserInfoBase.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['account_id'];
    name = json['name'];
    username = json['username'];
    companyId = json['company_id'];
    avatar = json['avatar'];
    telephone = json['telephone'];
    description = json['description'];
    status = json['status'];
    type = json['type'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
    registerFrom = json['register_from'];
    languageId = json['language_id'];
    tourist = json['tourist'];
    email = json['email'];
    nickname = json['nickname'];
    wechat = json['wechat'];
    customerId = json['customer_id'];
    lastOrderTime = json['last_order_time'];
    userMainId = json['user_main_id'];
    shopId = json['shop_id'];
    token = json['token'];
    isAuthAccount = _asBool(json['is_auth_account']);
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

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = '$value'.trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}
