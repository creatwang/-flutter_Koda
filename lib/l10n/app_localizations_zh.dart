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
  String productScanInvalidQrWithContent(Object code) {
    return '无效的二维码\\n扫码内容：$code';
  }

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
  String productAddedToCartSuccess(Object title) {
    return '已加入购物车！$title';
  }

  @override
  String productAddedToPreOrder(Object title) {
    return '已加入预订单！$title';
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

  @override
  String get commonOk => '确定';

  @override
  String get commonBack => '返回';

  @override
  String get commonSave => '保存';

  @override
  String get commonRemove => '移除';

  @override
  String get commonClear => '清空';

  @override
  String get commonClearAll => '全部清空';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonEditVerb => '编辑';

  @override
  String get commonDone => '完成';

  @override
  String get commonSubmit => '提交';

  @override
  String get commonPreview => '预览';

  @override
  String get commonExport => '导出';

  @override
  String get commonAdd => '添加';

  @override
  String get commonDelete => '删除';

  @override
  String get commonSearch => '搜索';

  @override
  String get commonRequired => '必填';

  @override
  String get commonMinSixChars => '至少 6 个字符';

  @override
  String get commonMinSixCharsShort => '至少 6 位';

  @override
  String get commonNotMatch => '不一致';

  @override
  String get commonDepartment => '部门';

  @override
  String get commonSpace => 'Space';

  @override
  String get commonSpaceDefault => '默认';

  @override
  String get commonUnknownDepartment => '未知部门';

  @override
  String get commonSuccess => '成功';

  @override
  String get commonActions => '操作';

  @override
  String get commonLogin => '登录';

  @override
  String get commonPrice => '价格';

  @override
  String get commonUnit => '单位';

  @override
  String get commonModel => '型号';

  @override
  String get commonHot => '热卖';

  @override
  String get commonProduct => '产品：';

  @override
  String get commonNoProduct => '无商品';

  @override
  String get homeNavHome => '首页';

  @override
  String get homeNavProfile => '我的';

  @override
  String get homeStartTitle => '现代家具';

  @override
  String get homeStartSubtitle => '用 Panto 轻松快速打造更极简的空间';

  @override
  String get homeStartShopping => '开始购物';

  @override
  String get authEmailLabel => '邮箱';

  @override
  String get authEmailHint => 'name@firm.com';

  @override
  String get authPasswordLabel => '密码';

  @override
  String get authLoginSuccess => '登录成功';

  @override
  String get cartGoToPreOrder => '前往预订单';

  @override
  String get cartShoppingCart => '购物车';

  @override
  String cartSummaryTotalNum(int count) {
    return '共 $count 件商品';
  }

  @override
  String get cartProjectSummary => '项目摘要';

  @override
  String get cartTotalItemsSelected => '已选商品数';

  @override
  String get cartEstimatedTotalAmount => '预估总金额';

  @override
  String get cartPreSubmitOrder => '预提交订单';

  @override
  String get cartPreOrder => '预订单';

  @override
  String get cartRemoveLineTitle => '移除此行？';

  @override
  String cartItemsCount(int count) {
    return '$count 件';
  }

  @override
  String get cartSelectSm => '选择 SM';

  @override
  String get cartNoSm => '无 SM';

  @override
  String get cartSelectSalesRep => '选择销售代表';

  @override
  String get cartNoMatchingSalesRep => '无匹配的销售代表';

  @override
  String get cartRemarkHint => '请输入备注';

  @override
  String get cartSpaceDialogSubtitle => '为购物车行添加简短标签，便于整理。';

  @override
  String get cartRemoveSelectedTitle => '移除所选行？';

  @override
  String get cartClearShortlistTitle => '清空整个清单？';

  @override
  String cartRemoveSelectedMessage(int count) {
    return '将从清单中移除 $count 条所选商品。';
  }

  @override
  String get cartClearShortlistMessage => '将清空当前站点下已加载的全部购物车行。';

  @override
  String get cartSelectedLinesRemoved => '已删除选中商品';

  @override
  String get cartShortlistCleared => '购物车已清空';

  @override
  String get cartRemoveSelectedFailed => '删除选中失败，请稍后再试';

  @override
  String get cartClearFailed => '清空失败，请稍后再试';

  @override
  String get cartExportQuotation => '导出报价单';

  @override
  String preOrderLoadFailed(Object error) {
    return '预订单加载失败：$error';
  }

  @override
  String get preOrderEmpty => '暂无预订单商品';

  @override
  String get preOrderTotalPrefix => '合计：';

  @override
  String get preOrderTotalSuffix => ' 件';

  @override
  String get preOrderGoToCheckout => '去结算';

  @override
  String get preOrderExportConfigEmpty => '导出表单配置为空。';

  @override
  String get preOrderQuotationExported => '报价单已导出';

  @override
  String preOrderExportSavedMessage(Object fileName, Object filePath) {
    return '文件：$fileName\n\n保存至：\n$filePath';
  }

  @override
  String get preOrderCheckoutFailed => '结算失败';

  @override
  String get preOrderOrderCreated => '订单创建成功';

  @override
  String get preOrderQuotationPreview => '报价单预览';

  @override
  String get preOrderPreviewUnavailable => '此设备不支持预览。';

  @override
  String get productTechnicalData => '技术参数';

  @override
  String productRefCode(Object code) {
    return '编号 $code';
  }

  @override
  String get productSortDefault => '默认';

  @override
  String get productSortPriceLowHigh => '价格（低到高）';

  @override
  String get productSortPriceHighLow => '价格（高到低）';

  @override
  String get productSortRatingHighest => '评分（最高）';

  @override
  String get productSortRatingLowest => '评分（最低）';

  @override
  String get productSortModelAz => '型号（A-Z）';

  @override
  String get productSortModelZa => '型号（Z-A）';

  @override
  String get productSortDateOldNew => '上架时间（旧到新）';

  @override
  String get productSortDateNewOld => '上架时间（新到旧）';

  @override
  String get productExpandFilterSidebar => '展开筛选侧栏';

  @override
  String productSortBy(Object label) {
    return '排序：$label';
  }

  @override
  String get productInShowroom => '展厅现货';

  @override
  String get productSearchHint => '搜索';

  @override
  String get productClearSearch => '清除搜索';

  @override
  String get productLibrary => '商品库';

  @override
  String get productFilters => '筛选';

  @override
  String get productCategories => '商品分类';

  @override
  String get productNoCategories => '暂无分类';

  @override
  String get profileSettingsUpdated => '更新成功';

  @override
  String get profileSwitchedToMainAccount => '已切换回主账号';

  @override
  String get profileAccountSettings => '账号设置';

  @override
  String get profilePersonalInformation => '个人信息';

  @override
  String get profileFullNameLabel => '姓名';

  @override
  String get profileOldPasswordLabel => '原密码';

  @override
  String get profileNewPasswordLabel => '新密码';

  @override
  String get profileConfirmPasswordLabel => '确认密码';

  @override
  String get profileSaveChanges => '保存修改';

  @override
  String get profileOtherSettings => '其他设置';

  @override
  String get profileSwitchSiteTooltip => '切换站点';

  @override
  String get profileSessionHint => '管理当前会话与登录账号。';

  @override
  String get profileSwitchAccount => '切换账号';

  @override
  String get profileSwitchAccountSubtitle => '切回原始账号';

  @override
  String get profileSignOut => '退出登录';

  @override
  String get profileSignOutSubtitle => '退出当前账号';

  @override
  String get profileSettingsNameRequired => '请输入姓名。';

  @override
  String get profileSettingsPasswordFieldsRequired => '请填写全部密码字段。';

  @override
  String get profileSettingsPasswordMinLength => '密码至少 6 位。';

  @override
  String get profileSettingsPasswordMismatch => '新密码与确认密码不一致。';

  @override
  String profileSectionEmpty(Object title) {
    return '$title 暂无内容';
  }

  @override
  String profileUid(Object id) {
    return 'UID：$id';
  }

  @override
  String profileSiteId(Object id) {
    return '站点 ID：$id';
  }

  @override
  String get profileFavNum => '收藏数';

  @override
  String get profileCartNum => '购物车数';

  @override
  String get profileAccountPreferences => '账号与偏好';

  @override
  String get profileAddCustomer => '添加客户';

  @override
  String get profileSetCommandPassword => '设置指令密码';

  @override
  String get profileBackToList => '返回列表';

  @override
  String get profileFavoritesEmpty => '暂无收藏';

  @override
  String get profileLoggedInAsCustomer => '已以客户身份登录。';

  @override
  String get profileCustomerDeleted => '已删除';

  @override
  String get profileNoCustomers => '暂无客户';

  @override
  String get profileCustomerName => '客户名称';

  @override
  String get profileUidHeader => 'UID';

  @override
  String get profileDeleteCustomer => '删除客户';

  @override
  String profileDeleteCustomerConfirm(Object name, Object username) {
    return '移除 $name（$username）？';
  }

  @override
  String get profileOrderTabMy => '我的';

  @override
  String get profileOrderTabCustomer => '客户';

  @override
  String get profileNoOrders => '暂无订单';

  @override
  String get profileOrderStatusSuccessful => '成功';

  @override
  String get profileOrderStatusFail => '失败';

  @override
  String get profileOrderSendToErp => '已发送至 ERP';

  @override
  String get profileOrderNotSentToErp => '未发送至 ERP';

  @override
  String get profileOrderNoLabel => '订单号：';

  @override
  String profileOrderTime(Object time) {
    return '时间：$time';
  }

  @override
  String get profileMenuSettings => '设置';

  @override
  String get profileMenuMyCustomers => '我的客户';

  @override
  String get profileMenuOrderCenter => '订单中心';

  @override
  String get profileMenuFavorites => '收藏';

  @override
  String get profileCustomerNew => '新建客户';

  @override
  String get profileCustomerEdit => '编辑客户';

  @override
  String get profileCustomerUsernameRequired => '请输入用户名或邮箱。';

  @override
  String get profileCustomerPasswordMinLength => '密码至少 6 位。';

  @override
  String get profileCustomerUsernameLabel => '用户名或邮箱';

  @override
  String get profileCustomerPasswordLabel => '密码';

  @override
  String get profileCustomerNameLabel => '姓名';

  @override
  String get profileCustomerPhoneLabel => '电话';

  @override
  String get profileCustomerUsernameHint => '该客户的登录标识。';

  @override
  String get profileCustomerPasswordHint => '创建与更新时必填（至少 6 位）。';

  @override
  String get profileCustomerNameHint => '显示名称。';

  @override
  String get profileCustomerPhoneHint => '联系电话。';

  @override
  String get profileCommandPasswordTitle => '设置指令密码';

  @override
  String get profileCommandPasswordHint => '作为本店客户账号的共用密码。';

  @override
  String get profileSwitchSiteTitle => '切换站点';

  @override
  String get profileNoSites => '暂无可用站点。';

  @override
  String profileSiteFallbackTitle(int id) {
    return '站点 #$id';
  }

  @override
  String profileSiteCurrent(int id) {
    return '当前站点 · ID：$id';
  }

  @override
  String profileSiteIdLine(int id) {
    return 'ID：$id';
  }

  @override
  String get sessionEndedTitle => '会话已结束';

  @override
  String get sessionEndedMessage => '请重新登录以继续购物。';

  @override
  String get sessionEndedSignIn => '重新登录';

  @override
  String get errorMissingCompanyId => '缺少站点 ID';

  @override
  String get errorMissingToken => '缺少 token';

  @override
  String get errorInvalidProductResponseFormat => '商品响应格式无效';

  @override
  String get errorInvalidProductsListFormat => '商品列表格式无效';

  @override
  String get errorInvalidFavoritesResponseFormat => '收藏响应格式无效';

  @override
  String get errorInvalidFavoritesListFormat => '收藏列表格式无效';

  @override
  String get errorInvalidCategoryTreeResponseFormat => '分类树响应格式无效';

  @override
  String get errorInvalidProductDetailResponseFormat => '商品详情响应格式无效';

  @override
  String get errorInvalidCartNumResponseFormat => '购物车数量响应格式无效';

  @override
  String get errorCartNumRequestFailed => '购物车数量请求失败';

  @override
  String get errorMissingCartNumResult => '购物车数量响应缺少 result';

  @override
  String get errorInvalidCartListResponseFormat => '购物车列表响应格式无效';

  @override
  String get errorUpdateCartSelectedFailed => '更新购物车选中状态失败';

  @override
  String get errorUpdateRemarkFailed => '更新备注失败';

  @override
  String get errorChangeCartQuantityFailed => '修改购买数量失败';

  @override
  String get errorDeleteCartItemFailed => '删除购物车行失败';

  @override
  String get errorCreateOrderFailed => '创建订单失败';

  @override
  String errorPleaseSelectSm(Object label) {
    return '请选择 SM（$label）';
  }

  @override
  String get errorNoSalesRepSelections => '没有可提交的销售代表选择。';

  @override
  String get errorSetSmFailed => '设置 SM 失败';

  @override
  String get errorInvalidSmSelection => 'SM 选择无效';

  @override
  String get errorAddToCartFailed => '加购失败';

  @override
  String get errorInvalidQuotationConfigResponseFormat => '报价配置响应格式无效';

  @override
  String get errorExportQuotationResponseEmpty => '导出报价响应为空';

  @override
  String get errorExportQuotationFailed => '导出报价失败';

  @override
  String get errorInvalidPreviewResponseFormat => '预览响应格式无效';

  @override
  String get errorPreviewUrlEmpty => '预览地址为空';

  @override
  String get errorInvalidUserInfoResponseFormat => '用户信息响应格式无效';

  @override
  String get errorUpdateUserInfoFailed => '更新用户信息失败';

  @override
  String get errorInvalidOrderListResponseFormat => '订单列表响应格式无效';

  @override
  String get errorInvalidCustomerListResponse => '客户列表响应无效';

  @override
  String get errorCreateCustomerFailed => '创建客户失败';

  @override
  String get errorUpdateCustomerFailed => '更新客户失败';

  @override
  String get errorResetCommonPasswordFailed => '重置共用密码失败';

  @override
  String get errorDeleteCustomerFailed => '删除客户失败';

  @override
  String get errorInvalidCustomerLoginResponse => '客户登录响应无效';

  @override
  String get errorInvalidCompanyListResponse => '站点列表响应无效';

  @override
  String get errorMissingItemsInCompanyList => '站点列表缺少 items';

  @override
  String get errorInvalidSwitchShopResponse => '切换站点响应无效';

  @override
  String get errorMissingCompanyIdInSwitchResponse => '切换响应缺少 company_id';

  @override
  String get errorMissingTokenInSwitchResponse => '切换响应缺少 token';

  @override
  String get errorLogoutFailed => '退出登录失败';

  @override
  String get errorLogoutRequestFailed => '退出登录请求失败';

  @override
  String get errorInvalidLoginResponseFormat => '登录响应格式无效';

  @override
  String get errorInvalidCompanyIdInLoginResponse => '登录响应缺少 company_id';

  @override
  String get errorInvalidRegisterResponseFormat => '注册响应格式无效';

  @override
  String get errorInvalidCompanyIdInRegisterResponse => '注册响应缺少 company_id';

  @override
  String get errorRequestFailed => '请求失败';

  @override
  String get errorNetworkError => '网络错误';

  @override
  String get errorSessionExpiredDefault => '您的登录已过期，请重新登录。';

  @override
  String get errorPleaseSignInFirst => '请先登录';

  @override
  String get errorInvalidProductQuantity => '商品数量无效';

  @override
  String get errorCreateFavoriteFailed => '添加收藏失败';

  @override
  String get errorDeleteFavoriteFailed => '取消收藏失败';

  @override
  String get errorFetchSiteInfoFailed => '获取站点信息失败';

  @override
  String get errorInvalidUserPayloadAfterSwitch => '切换后用户数据无效';

  @override
  String get errorUserInfoMissing => '缺少用户信息';

  @override
  String get errorInvalidCustomerSession => '客户会话无效';

  @override
  String get errorNoMainAccountToSwitch => '没有可切换的主账号';

  @override
  String get errorInvalidMainAccountSnapshot => '主账号快照无效';

  @override
  String get cartUnorderedNoticeTitle => '提示';

  @override
  String get cartUnorderedItemsDefault => '购物车中仍有未下单商品。';

  @override
  String get cartGoToCart => '前往购物车';

  @override
  String get toastSuccess => '成功';

  @override
  String get toastInfo => '提示';

  @override
  String get toastWarning => '警告';

  @override
  String get toastError => '错误';

  @override
  String get debugSecureStorageTitle => 'Secure Storage 调试';

  @override
  String get debugRefresh => '刷新';

  @override
  String get debugMaskValues => '值脱敏显示';

  @override
  String get debugMaskValuesSubtitle => '关闭后将展示完整明文';

  @override
  String get debugClearAllKeys => '清空全部键值';

  @override
  String get debugNoStorageContent => '当前没有存储内容';

  @override
  String get debugDeleteKey => '删除该键';

  @override
  String get debugLocalOnlyWarning => '仅用于本地调试，请勿在生产环境保留该页面入口。';

  @override
  String debugLoadFailed(String error) {
    return '读取失败: $error';
  }

  @override
  String get debugEmptyStringPlaceholder => '(空字符串)';

  @override
  String get errorCustomerLoginFailed => '客户登录失败';

  @override
  String get errorFetchProductsFailed => '获取商品失败';

  @override
  String get errorFetchFavoritesFailed => '获取收藏失败';

  @override
  String get errorFetchCategoryTreeFailed => '获取分类树失败';

  @override
  String get errorFetchProductDetailFailed => '获取商品详情失败';

  @override
  String get errorFetchCartNumFailed => '获取购物车数量失败';

  @override
  String get errorFetchCartListFailed => '获取购物车列表失败';

  @override
  String get errorClearCartFailed => '清空购物车失败';

  @override
  String get errorChangeCartSpecFailed => '修改规格失败';

  @override
  String get errorQuotationConfigRequestFailed => '报价配置请求失败';

  @override
  String get errorFetchQuotationConfigFailed => '获取报价配置失败';

  @override
  String get errorPreviewQuotationFailed => '预览报价失败';

  @override
  String get errorFetchUserInfoFailed => '获取用户信息失败';

  @override
  String get errorFetchOrderListFailed => '获取订单列表失败';

  @override
  String get errorLoginRequestFailed => '登录请求失败';

  @override
  String get errorCartNotReady => '购物车未就绪';

  @override
  String get errorFetchCustomersFailed => '获取客户列表失败';

  @override
  String get errorFetchCompanyListFailed => '获取站点列表失败';

  @override
  String get errorRegisterRequestFailed => '注册请求失败';

  @override
  String get errorSwitchShopFailed => '切换站点失败';
}
