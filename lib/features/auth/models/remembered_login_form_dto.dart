/// 本地「记住登录」表单快照（非接口返回模型）。
class RememberedLoginFormDto {
  const RememberedLoginFormDto({
    required this.username,
    this.password,
  });

  final String username;
  final String? password;

  bool get hasSavedPassword => password?.isNotEmpty ?? false;
}
