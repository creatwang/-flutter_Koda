class UserInfoBase {
  num? id;
  num? accountId;
  String? name;
  String? username;
  num? companyId;
  String? avatar;
  Null? telephone;
  Null? description;
  num? status;
  num? type;
  String? updatedAt;
  String? createdAt;
  Null? deletedAt;
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
  bool? isAuthAccount;

  UserInfoBase(
      {this.id,
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
        this.isAuthAccount});

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
    isAuthAccount = json['is_auth_account'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['account_id'] = this.accountId;
    data['name'] = this.name;
    data['username'] = this.username;
    data['company_id'] = this.companyId;
    data['avatar'] = this.avatar;
    data['telephone'] = this.telephone;
    data['description'] = this.description;
    data['status'] = this.status;
    data['type'] = this.type;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['deleted_at'] = this.deletedAt;
    data['register_from'] = this.registerFrom;
    data['language_id'] = this.languageId;
    data['tourist'] = this.tourist;
    data['email'] = this.email;
    data['nickname'] = this.nickname;
    data['wechat'] = this.wechat;
    data['customer_id'] = this.customerId;
    data['last_order_time'] = this.lastOrderTime;
    data['user_main_id'] = this.userMainId;
    data['shop_id'] = this.shopId;
    data['token'] = this.token;
    data['is_auth_account'] = this.isAuthAccount;
    return data;
  }
}