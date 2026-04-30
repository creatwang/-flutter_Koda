// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'George 商城';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonNoData => '暂无数据';

  @override
  String get commonRetry => '重试';

  @override
  String get commonLogout => '退出登录';

  @override
  String get splashSessionInitializing => '正在初始化会话…';

  @override
  String get languageLabel => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => '英文';

  @override
  String get homeCategory => '产品分类';

  @override
  String get homeProducts => '商品';

  @override
  String get homeCart => '购物车';

  @override
  String homeCartWithCount(int count) {
    return '购物车($count)';
  }

  @override
  String get loginTitle => 'iPad 商城登录';

  @override
  String get authLoginHeading => '登录';

  @override
  String get authRegisterHeading => '创建账户';

  @override
  String get authNewHereHint => '新用户？';

  @override
  String get authHaveAccountHint => '已有账号？';

  @override
  String get authLoginTab => '登录';

  @override
  String get authRegisterTab => '注册';

  @override
  String get loginUsername => '用户名';

  @override
  String get loginPassword => '密码';

  @override
  String get authConfirmPasswordLabel => '确认密码';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authRememberMe => '30 天内保持登录';

  @override
  String get loginAction => '登录';

  @override
  String get authLoginAction => '去登录';

  @override
  String get authRegisterAction => '创建账户';

  @override
  String get loginFailed => '登录失败，请检查账号密码';

  @override
  String get authPasswordMismatch => '两次密码不一致';

  @override
  String get authRegisterUsernameRequired => '请输入用户名';

  @override
  String get authRegisterPasswordMinLength => '密码至少 6 位';

  @override
  String get authRegisterFailed => '注册失败，请稍后重试';

  @override
  String productLoadFailed(Object error) {
    return '商品加载失败: $error';
  }

  @override
  String get productEmpty => '暂无商品';

  @override
  String productDetailLoadFailed(Object error) {
    return '详情加载失败: $error';
  }

  @override
  String get productDetailVariantsEmpty => '商品规格数据为空';

  @override
  String get productDetailBackToList => '返回案例列表';

  @override
  String get productDetailMasterpieceCollection => '大师系列';

  @override
  String get productDetailBuyNow => '立即购买';

  @override
  String get productScanTooltip => '扫描二维码';

  @override
  String get productScanRequireLogin => '请先登录后再扫码';

  @override
  String productScanResult(Object code) {
    return '扫码结果：$code';
  }

  @override
  String get productScanTitle => '扫描二维码';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确定';

  @override
  String get cartSpaceDialogTitle => '请输入 Space';

  @override
  String get cartSpaceDialogHint => '必填';

  @override
  String get cartAddRequireLogin => '请先登录后再加购';

  @override
  String get cartConfirmAdd => '确认加购';

  @override
  String get cartConfirmChangeSpec => '确认修改规格';

  @override
  String get cartNoMatchedSku => '未找到在售 SKU';

  @override
  String get cartAddBlockedZeroSalesPrice => '销售价为 0 时无法加购';

  @override
  String get cartQuantityLabel => '数量';

  @override
  String get cartChangeSpec => '改规格';

  @override
  String get cartSkuDrawerClose => '关闭';

  @override
  String get cartSkuDrawerProductLine => '产品';

  @override
  String get addToCart => '加入购物车';

  @override
  String productAddedToCart(Object title) {
    return '已加入购物车: $title';
  }

  @override
  String cartLoadFailed(Object error) {
    return '购物车加载失败: $error';
  }

  @override
  String get cartEmpty => '购物车为空';

  @override
  String cartTotal(Object amount) {
    return '合计: \$ $amount';
  }

  @override
  String webMessageFromHtml(Object message) {
    return '来自 Web 的消息: $message';
  }

  @override
  String get webNotSupported => 'Web 端暂不支持内嵌 WebView，请使用移动端或桌面端查看';

  @override
  String get webViewNotSupported => '当前平台不支持 WebView（或测试环境未注入平台实现）';

  @override
  String get sendMessageToHtml => 'Flutter -> HTML 发送消息';

  @override
  String flutterMessageCounter(int count) {
    return 'Flutter 消息 #$count';
  }
}
