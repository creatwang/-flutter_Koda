/// 加购时购物车仍有未下单商品（`POST /store/cart/create`）。
const int cartUnorderedItemsBusinessCode = 100000;

bool isCartUnorderedItemsBusinessCode(String? code) =>
    code == cartUnorderedItemsBusinessCode.toString();

/// 与 [ResponseDataModeInterceptor]、各 `*_services` 对齐的业务成功 `code` 判定。
///
/// 约定：成功为 `0` / `200`（数值或字符串），或字符串 `success`；缺省 `code`
/// 视为成功（由具体接口再收紧）。
bool isApiBusinessSuccessCode(dynamic code) {
  if (code == null) return true;
  if (code is num) return code == 0 || code == 200;
  if (code is String) {
    final t = code.trim().toLowerCase();
    return t == '0' || t == '200' || t == 'success';
  }
  return false;
}
