// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'George Mall';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonNoData => 'No data';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLogout => 'Sign out';

  @override
  String get splashSessionInitializing => 'Starting session…';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageEnglish => 'English';

  @override
  String get homeCategory => 'Categories';

  @override
  String get homeProducts => 'Products';

  @override
  String get homeCart => 'Cart';

  @override
  String homeCartWithCount(int count) {
    return 'Cart($count)';
  }

  @override
  String get loginTitle => 'iPad Mall Sign In';

  @override
  String get authLoginHeading => 'Login';

  @override
  String get authRegisterHeading => 'Create an account';

  @override
  String get authNewHereHint => 'New here?';

  @override
  String get authHaveAccountHint => 'Already have an account?';

  @override
  String get authLoginTab => 'Login';

  @override
  String get authRegisterTab => 'Register';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authForgotPassword => 'Forgot?';

  @override
  String get authRememberMe => 'Keep me signed in for 30 days';

  @override
  String get loginAction => 'Sign in';

  @override
  String get authLoginAction => 'Sign in';

  @override
  String get authRegisterAction => 'Create account';

  @override
  String get loginFailed => 'Sign in failed. Please check your credentials.';

  @override
  String get authPasswordMismatch => 'Passwords do not match.';

  @override
  String get authRegisterUsernameRequired => 'Please enter a username.';

  @override
  String get authRegisterPasswordMinLength =>
      'Password must be at least 6 characters.';

  @override
  String get authRegisterFailed => 'Registration failed. Please try again.';

  @override
  String productLoadFailed(Object error) {
    return 'Failed to load products: $error';
  }

  @override
  String get productEmpty => 'No products';

  @override
  String productDetailLoadFailed(Object error) {
    return 'Failed to load details: $error';
  }

  @override
  String get productDetailVariantsEmpty => 'Product variants are empty';

  @override
  String get productDetailBackToList => 'Back to Case Studies';

  @override
  String get productDetailMasterpieceCollection => 'MASTERPIECE COLLECTION';

  @override
  String get productDetailBuyNow => 'Buy Now';

  @override
  String get productScanTooltip => 'Scan QR code';

  @override
  String get productScanRequireLogin => 'Please sign in before scanning';

  @override
  String productScanResult(Object code) {
    return 'Scan result: $code';
  }

  @override
  String get productScanTitle => 'Scan QR Code';

  @override
  String productScanInvalidQrWithContent(Object code) {
    return 'Invalid QR code\\nScanned content: $code';
  }

  @override
  String get productScanUniqidsListTitle => 'Scanned products';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get cartSpaceDialogTitle => 'Enter Space';

  @override
  String get cartSpaceDialogHint => 'Required';

  @override
  String get cartAddRequireLogin => 'Please sign in before adding to cart';

  @override
  String get cartConfirmAdd => 'Add to cart';

  @override
  String get cartConfirmChangeSpec => 'Save specification';

  @override
  String get cartNoMatchedSku => 'No on-sale SKU matched';

  @override
  String get cartAddBlockedZeroSalesPrice =>
      'Cannot add to cart when sales price is 0';

  @override
  String get cartQuantityLabel => 'Quantity';

  @override
  String get cartChangeSpec => 'Change spec';

  @override
  String get cartSkuDrawerClose => 'Close';

  @override
  String get cartSkuDrawerProductLine => 'Product';

  @override
  String get addToCart => 'Add to cart';

  @override
  String productAddedToCart(Object title) {
    return 'Added to cart: $title';
  }

  @override
  String productAddedToCartSuccess(Object title) {
    return 'Added to cart! $title';
  }

  @override
  String productAddedToPreOrder(Object title) {
    return 'Added to pre-order! $title';
  }

  @override
  String cartLoadFailed(Object error) {
    return 'Failed to load cart: $error';
  }

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String cartTotal(Object amount) {
    return 'Total: \$ $amount';
  }

  @override
  String webMessageFromHtml(Object message) {
    return 'Message from Web: $message';
  }

  @override
  String get webNotSupported =>
      'Web does not support embedded WebView yet. Please use mobile or desktop.';

  @override
  String get webViewNotSupported =>
      'Current platform does not support WebView (or test environment has no platform implementation).';

  @override
  String get sendMessageToHtml => 'Send Flutter -> HTML message';

  @override
  String flutterMessageCounter(int count) {
    return 'Flutter message #$count';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonClearAll => 'Clear all';

  @override
  String get commonEdit => 'EDIT';

  @override
  String get commonEditVerb => 'Edit';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonPreview => 'Preview';

  @override
  String get commonExport => 'Export';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonMinSixChars => 'Min 6 characters';

  @override
  String get commonMinSixCharsShort => 'Min 6 chars';

  @override
  String get commonNotMatch => 'Not match';

  @override
  String get commonDepartment => 'Department';

  @override
  String get commonSpace => 'Space';

  @override
  String get commonSpaceDefault => 'default';

  @override
  String get commonUnknownDepartment => 'Unknown Department';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonActions => 'ACTIONS';

  @override
  String get commonLogin => 'LOGIN';

  @override
  String get commonPrice => 'Price';

  @override
  String get commonUnit => 'Unit';

  @override
  String get commonModel => 'Model';

  @override
  String get commonHot => 'HOT';

  @override
  String get commonProduct => 'PRODUCT:';

  @override
  String get commonNoProduct => 'no product';

  @override
  String get homeNavHome => 'Home';

  @override
  String get homeNavProfile => 'Profile';

  @override
  String get homeStartTitle => 'Modern Furniture';

  @override
  String get homeStartSubtitle =>
      'Turn your room with panto into a lot more minimalist with ease and speed';

  @override
  String get homeStartShopping => 'Start Shopping';

  @override
  String get authEmailLabel => 'EMAIL ADDRESS';

  @override
  String get authEmailHint => 'name@firm.com';

  @override
  String get authPasswordLabel => 'PASSWORD';

  @override
  String get authLoginSuccess => 'Signed in successfully.';

  @override
  String get cartGoToPreOrder => 'Go To Pre Order';

  @override
  String get cartShoppingCart => 'Shopping Cart';

  @override
  String cartSummaryTotalNum(int count) {
    return 'Total num $count items';
  }

  @override
  String get cartProjectSummary => 'PROJECT SUMMARY';

  @override
  String get cartTotalItemsSelected => 'Total items selected';

  @override
  String get cartEstimatedTotalAmount => 'ESTIMATED TOTAL AMOUNT';

  @override
  String get cartPreSubmitOrder => 'Pre Submit Order';

  @override
  String get cartPreOrder => 'Pre Order';

  @override
  String get cartRemoveLineTitle => 'Remove this line?';

  @override
  String cartItemsCount(int count) {
    return '$count ITEMS';
  }

  @override
  String get cartSelectSm => 'Select SM';

  @override
  String get cartNoSm => 'No SM';

  @override
  String get cartSelectSalesRep => 'Select Sales Rep';

  @override
  String get cartNoMatchingSalesRep => 'No matching sales rep';

  @override
  String get cartRemarkHint => 'Please edit content';

  @override
  String get cartSpaceDialogSubtitle =>
      'One short tag for this cart line — keeps picks organized.';

  @override
  String get cartRemoveSelectedTitle => 'Remove selected lines?';

  @override
  String get cartClearShortlistTitle => 'Clear entire shortlist?';

  @override
  String cartRemoveSelectedMessage(int count) {
    return '$count selected lines will be removed from your shortlist.';
  }

  @override
  String get cartClearShortlistMessage =>
      'This clears all cart lines currently loaded for your sites.';

  @override
  String get cartSelectedLinesRemoved => 'Selected lines removed';

  @override
  String get cartShortlistCleared => 'Cart cleared';

  @override
  String get cartRemoveSelectedFailed =>
      'Failed to remove selected lines. Please try again.';

  @override
  String get cartClearFailed => 'Failed to clear cart. Please try again.';

  @override
  String get cartExportQuotation => 'Export Quotation';

  @override
  String preOrderLoadFailed(Object error) {
    return 'Pre order load failed: $error';
  }

  @override
  String get preOrderEmpty => 'No pre-order items';

  @override
  String get preOrderTotalPrefix => 'Total: ';

  @override
  String get preOrderTotalSuffix => ' items';

  @override
  String get preOrderGoToCheckout => 'Go To Checkout';

  @override
  String get preOrderExportConfigEmpty => 'Export form config is empty.';

  @override
  String get preOrderQuotationExported => 'Quotation exported';

  @override
  String preOrderExportSavedMessage(Object fileName, Object filePath) {
    return 'File: $fileName\n\nSaved to:\n$filePath';
  }

  @override
  String get preOrderCheckoutFailed => 'Checkout failed';

  @override
  String get preOrderOrderCreated => 'Order created successfully';

  @override
  String get preOrderQuotationPreview => 'Quotation Preview';

  @override
  String get preOrderPreviewUnavailable =>
      'Preview is not available on this device.';

  @override
  String get productTechnicalData => 'Technical Data';

  @override
  String productRefCode(Object code) {
    return 'Ref. $code';
  }

  @override
  String get productSortDefault => 'Default';

  @override
  String get productSortPriceLowHigh => 'Price(Low > High)';

  @override
  String get productSortPriceHighLow => 'Price(Low < High)';

  @override
  String get productSortRatingHighest => 'Rating(Highest)';

  @override
  String get productSortRatingLowest => 'Rating(Lowest)';

  @override
  String get productSortModelAz => 'Model(A - Z)';

  @override
  String get productSortModelZa => 'Model(Z - A)';

  @override
  String get productSortDateOldNew => 'Date Added(Old >New)';

  @override
  String get productSortDateNewOld => 'Date Added(New >Old)';

  @override
  String get productExpandFilterSidebar => 'Expand filter sidebar';

  @override
  String productSortBy(Object label) {
    return 'Sort by: $label';
  }

  @override
  String get productInShowroom => 'In Showroom';

  @override
  String get productSearchHint => 'Please';

  @override
  String get productClearSearch => 'Clear search';

  @override
  String get productLibrary => 'Product Library';

  @override
  String get productFilters => 'Filters';

  @override
  String get productCategories => 'Product Categories';

  @override
  String get productNoCategories => 'No categories';

  @override
  String get profileSettingsUpdated => 'Updated successfully.';

  @override
  String get profileSwitchedToMainAccount => 'Switched to main account.';

  @override
  String get profileAccountSettings => 'Account Settings';

  @override
  String get profilePersonalInformation => 'Personal Information';

  @override
  String get profileFullNameLabel => 'FULL NAME';

  @override
  String get profileOldPasswordLabel => 'OLD PASSWORD';

  @override
  String get profileNewPasswordLabel => 'NEW PASSWORD';

  @override
  String get profileConfirmPasswordLabel => 'CONFIRM PASSWORD';

  @override
  String get profileSaveChanges => 'Save Changes';

  @override
  String get profileOtherSettings => 'Another Settings';

  @override
  String get profileSwitchSiteTooltip => 'Switch site';

  @override
  String get profileSessionHint =>
      'Manage your active session and sign-in account.';

  @override
  String get profileSwitchAccount => 'Switch Account';

  @override
  String get profileSwitchAccountSubtitle => 'Switch back to original account';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutSubtitle => 'Exit current account';

  @override
  String get profileSettingsNameRequired => 'Name is required.';

  @override
  String get profileSettingsPasswordFieldsRequired =>
      'Please complete all password fields.';

  @override
  String get profileSettingsPasswordMinLength =>
      'Password must be at least 6 characters.';

  @override
  String get profileSettingsPasswordMismatch =>
      'New Password and Confirm Password must match.';

  @override
  String profileSectionEmpty(Object title) {
    return '$title is empty';
  }

  @override
  String profileUid(Object id) {
    return 'UID: $id';
  }

  @override
  String profileSiteId(Object id) {
    return 'SITEID: $id';
  }

  @override
  String profileSiteHost(Object host) {
    return 'SITE: $host';
  }

  @override
  String get profileFavNum => 'FAV NUM';

  @override
  String get profileCartNum => 'CART NUM';

  @override
  String get profileAccountPreferences => 'ACCOUNT & PREFERENCES';

  @override
  String get profileAddCustomer => 'Add Customer';

  @override
  String get profileSetCommandPassword => 'Set Command Password';

  @override
  String get profileBackToList => 'Back to list';

  @override
  String get profileFavoritesEmpty => 'Favorites is empty';

  @override
  String get profileLoggedInAsCustomer => 'Logged in as customer.';

  @override
  String get profileCustomerDeleted => 'Deleted';

  @override
  String get profileNoCustomers => 'No customers';

  @override
  String get profileCustomerName => 'CUSTOMER NAME';

  @override
  String get profileUidHeader => 'UID';

  @override
  String get profileDeleteCustomer => 'Delete customer';

  @override
  String profileDeleteCustomerConfirm(Object name, Object username) {
    return 'Remove $name ($username)?';
  }

  @override
  String get profileOrderTabMy => 'My';

  @override
  String get profileOrderTabCustomer => 'Customer';

  @override
  String get profileNoOrders => 'No orders yet';

  @override
  String get profileOrderStatusSuccessful => 'Successful';

  @override
  String get profileOrderStatusFail => 'Fail';

  @override
  String get profileOrderSendToErp => 'Send to ERP';

  @override
  String get profileOrderNotSentToErp => 'Not sent to ERP';

  @override
  String get profileOrderNoLabel => 'OrderNo:';

  @override
  String profileOrderTime(Object time) {
    return 'Time: $time';
  }

  @override
  String get profileMenuSettings => 'Settings';

  @override
  String get profileMenuMyCustomers => 'My Customers';

  @override
  String get profileMenuOrderCenter => 'Order Center';

  @override
  String get profileMenuFavorites => 'Favorites';

  @override
  String get profileCustomerNew => 'New Customer';

  @override
  String get profileCustomerEdit => 'Edit Customer';

  @override
  String get profileCustomerUsernameRequired =>
      'Username or Email is required.';

  @override
  String get profileCustomerPasswordMinLength =>
      'Password must be at least 6 characters.';

  @override
  String get profileCustomerUsernameLabel => 'USERNAME OR EMAIL';

  @override
  String get profileCustomerPasswordLabel => 'PASSWORD';

  @override
  String get profileCustomerNameLabel => 'NAME';

  @override
  String get profileCustomerPhoneLabel => 'PHONE';

  @override
  String get profileCustomerUsernameHint =>
      'Login identifier for this customer account.';

  @override
  String get profileCustomerPasswordHint =>
      'Required for create and update (min 6 characters).';

  @override
  String get profileCustomerNameHint => 'Display name.';

  @override
  String get profileCustomerPhoneHint => 'Contact telephone.';

  @override
  String get profileCommandPasswordTitle => 'Set Command Password';

  @override
  String get profileCommandPasswordHint =>
      'Applies as the shared customer account password for this store.';

  @override
  String get profileSwitchSiteTitle => 'Switch site';

  @override
  String get profileNoSites => 'No sites available.';

  @override
  String profileSiteFallbackTitle(int id) {
    return 'Site #$id';
  }

  @override
  String profileSiteCurrentDomain(Object host) {
    return 'Current site · $host';
  }

  @override
  String profileSiteCurrent(int id) {
    return 'Current site · ID: $id';
  }

  @override
  String profileSiteIdLine(int id) {
    return 'ID: $id';
  }

  @override
  String get sessionEndedTitle => 'Session ended';

  @override
  String get sessionEndedMessage =>
      'Please sign in again to continue shopping.';

  @override
  String get sessionEndedSignIn => 'Sign in again';

  @override
  String get errorMissingCompanyId => 'Missing company id';

  @override
  String get errorMissingStoreDomain => 'Missing store domain';

  @override
  String get errorInvalidSiteDomain => 'Invalid site domain';

  @override
  String get errorMissingToken => 'Missing token';

  @override
  String get errorInvalidProductResponseFormat =>
      'Invalid product response format';

  @override
  String get errorInvalidProductsListFormat => 'Invalid products list format';

  @override
  String get errorInvalidFavoritesResponseFormat =>
      'Invalid favorites response format';

  @override
  String get errorInvalidFavoritesListFormat => 'Invalid favorites list format';

  @override
  String get errorInvalidCategoryTreeResponseFormat =>
      'Invalid category tree response format';

  @override
  String get errorInvalidProductDetailResponseFormat =>
      'Invalid product detail response format';

  @override
  String get errorInvalidCartNumResponseFormat =>
      'Invalid cart num response format';

  @override
  String get errorCartNumRequestFailed => 'Cart num request failed';

  @override
  String get errorMissingCartNumResult => 'Missing result in cart num response';

  @override
  String get errorInvalidCartListResponseFormat =>
      'Invalid cart list response format';

  @override
  String get errorUpdateCartSelectedFailed => 'Update cart selected failed';

  @override
  String get errorUpdateRemarkFailed => 'Update remark failed';

  @override
  String get errorChangeCartQuantityFailed => 'Change cart quantity failed';

  @override
  String get errorDeleteCartItemFailed => 'Delete cart item failed';

  @override
  String get errorCreateOrderFailed => 'Create order failed';

  @override
  String errorPleaseSelectSm(Object label) {
    return 'Please select SM ($label)';
  }

  @override
  String get errorNoSalesRepSelections => 'No sales rep selections to submit.';

  @override
  String get errorSetSmFailed => 'Set SM failed';

  @override
  String get errorInvalidSmSelection => 'Invalid SM selection.';

  @override
  String get errorAddToCartFailed => 'Add to cart failed';

  @override
  String get errorInvalidQuotationConfigResponseFormat =>
      'Invalid quotation config response format';

  @override
  String get errorExportQuotationResponseEmpty =>
      'Export quotation response is empty';

  @override
  String get errorExportQuotationFailed => 'Export quotation failed';

  @override
  String get errorInvalidPreviewResponseFormat =>
      'Invalid preview response format';

  @override
  String get errorPreviewUrlEmpty => 'Preview url is empty';

  @override
  String get errorInvalidUserInfoResponseFormat =>
      'Invalid user info response format';

  @override
  String get errorUpdateUserInfoFailed => 'Update user info failed';

  @override
  String get errorInvalidOrderListResponseFormat =>
      'Invalid order list response format';

  @override
  String get errorInvalidCustomerListResponse =>
      'Invalid customer list response';

  @override
  String get errorCreateCustomerFailed => 'Create customer failed';

  @override
  String get errorUpdateCustomerFailed => 'Update customer failed';

  @override
  String get errorResetCommonPasswordFailed => 'Reset common password failed';

  @override
  String get errorDeleteCustomerFailed => 'Delete customer failed';

  @override
  String get errorInvalidCustomerLoginResponse =>
      'Invalid customer login response';

  @override
  String get errorInvalidCompanyListResponse => 'Invalid company list response';

  @override
  String get errorMissingItemsInCompanyList => 'Missing items in company list';

  @override
  String get errorInvalidSwitchShopResponse => 'Invalid switch shop response';

  @override
  String get errorMissingCompanyIdInSwitchResponse =>
      'Missing company_id in switch response';

  @override
  String get errorMissingTokenInSwitchResponse =>
      'Missing token in switch response';

  @override
  String get errorLogoutFailed => 'Logout failed';

  @override
  String get errorLogoutRequestFailed => 'Logout request failed';

  @override
  String get errorInvalidLoginResponseFormat => 'Invalid login response format';

  @override
  String get errorInvalidCompanyIdInLoginResponse =>
      'Invalid company_id in login response';

  @override
  String get errorInvalidDomainInLoginResponse =>
      'Invalid domain in login response';

  @override
  String get errorInvalidRegisterResponseFormat =>
      'Invalid register response format';

  @override
  String get errorInvalidCompanyIdInRegisterResponse =>
      'Invalid company_id in register response';

  @override
  String get errorInvalidDomainInRegisterResponse =>
      'Invalid domain in register response';

  @override
  String get errorRequestFailed => 'Request failed';

  @override
  String get errorNetworkError => 'Network error';

  @override
  String get errorSessionExpiredDefault =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorPleaseSignInFirst => 'Please sign in first.';

  @override
  String get errorInvalidProductQuantity => 'Invalid product quantity.';

  @override
  String get errorCreateFavoriteFailed => 'Create favorite failed';

  @override
  String get errorDeleteFavoriteFailed => 'Delete favorite failed';

  @override
  String get errorFetchSiteInfoFailed => 'Fetch site info failed';

  @override
  String get errorInvalidUserPayloadAfterSwitch =>
      'Invalid user payload after switch';

  @override
  String get errorUserInfoMissing => 'User info missing';

  @override
  String get errorInvalidCustomerSession => 'Invalid customer session';

  @override
  String get errorNoMainAccountToSwitch => 'No main account to switch';

  @override
  String get errorInvalidMainAccountSnapshot => 'Invalid main account snapshot';

  @override
  String get cartUnorderedNoticeTitle => 'Notice';

  @override
  String get cartUnorderedItemsDefault =>
      'There are still unordered items in the shopping cart.';

  @override
  String get cartGoToCart => 'Go to Cart';

  @override
  String get toastSuccess => 'Success!';

  @override
  String get toastInfo => 'Info';

  @override
  String get toastWarning => 'Warning';

  @override
  String get toastError => 'Error';

  @override
  String get debugSecureStorageTitle => 'Secure Storage Debug';

  @override
  String get debugRefresh => 'Refresh';

  @override
  String get debugMaskValues => 'Mask stored values';

  @override
  String get debugMaskValuesSubtitle => 'Turn off to show full plaintext';

  @override
  String get debugClearAllKeys => 'Clear all keys';

  @override
  String get debugNoStorageContent => 'No stored content yet';

  @override
  String get debugDeleteKey => 'Delete this key';

  @override
  String get debugLocalOnlyWarning =>
      'For local debugging only. Do not ship this page entry in production.';

  @override
  String debugLoadFailed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get debugEmptyStringPlaceholder => '(empty string)';

  @override
  String get errorCustomerLoginFailed => 'Customer login failed';

  @override
  String get errorFetchProductsFailed => 'Fetch products failed';

  @override
  String get errorFetchFavoritesFailed => 'Fetch favorites failed';

  @override
  String get errorFetchCategoryTreeFailed => 'Fetch category tree failed';

  @override
  String get errorFetchProductDetailFailed => 'Fetch product detail failed';

  @override
  String get errorFetchCartNumFailed => 'Fetch cart num failed';

  @override
  String get errorFetchCartListFailed => 'Fetch cart list failed';

  @override
  String get errorClearCartFailed => 'Clear cart failed';

  @override
  String get errorChangeCartSpecFailed => 'Change cart spec failed';

  @override
  String get errorQuotationConfigRequestFailed =>
      'Quotation config request failed';

  @override
  String get errorFetchQuotationConfigFailed => 'Fetch quotation config failed';

  @override
  String get errorPreviewQuotationFailed => 'Preview quotation failed';

  @override
  String get errorFetchUserInfoFailed => 'Fetch user info failed';

  @override
  String get errorFetchOrderListFailed => 'Fetch order list failed';

  @override
  String get errorLoginRequestFailed => 'Login request failed';

  @override
  String get errorCartNotReady => 'Cart not ready.';

  @override
  String get errorFetchCustomersFailed => 'Fetch customers failed';

  @override
  String get errorFetchCompanyListFailed => 'Fetch company list failed';

  @override
  String get errorRegisterRequestFailed => 'Register request failed';

  @override
  String get errorSwitchShopFailed => 'Switch shop failed';
}
