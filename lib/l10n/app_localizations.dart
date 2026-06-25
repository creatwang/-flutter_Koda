import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'George Mall'**
  String get appTitle;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get commonNoData;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonLogout;

  /// No description provided for @splashSessionInitializing.
  ///
  /// In en, this message translates to:
  /// **'Starting session…'**
  String get splashSessionInitializing;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @homeCategory.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategory;

  /// No description provided for @homeProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get homeProducts;

  /// No description provided for @homeCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get homeCart;

  /// No description provided for @homeCartWithCount.
  ///
  /// In en, this message translates to:
  /// **'Cart({count})'**
  String homeCartWithCount(int count);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'iPad Mall Sign In'**
  String get loginTitle;

  /// No description provided for @authLoginHeading.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginHeading;

  /// No description provided for @authRegisterHeading.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authRegisterHeading;

  /// No description provided for @authNewHereHint.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get authNewHereHint;

  /// No description provided for @authHaveAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccountHint;

  /// No description provided for @authLoginTab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginTab;

  /// No description provided for @authRegisterTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTab;

  /// No description provided for @loginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get authForgotPassword;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in for 30 days'**
  String get authRememberMe;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginAction;

  /// No description provided for @authLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginAction;

  /// No description provided for @authRegisterAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterAction;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatch;

  /// No description provided for @authRegisterUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get authRegisterUsernameRequired;

  /// No description provided for @authRegisterPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authRegisterPasswordMinLength;

  /// No description provided for @authRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get authRegisterFailed;

  /// No description provided for @productLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products: {error}'**
  String productLoadFailed(Object error);

  /// No description provided for @productEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get productEmpty;

  /// No description provided for @productDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load details: {error}'**
  String productDetailLoadFailed(Object error);

  /// No description provided for @productDetailVariantsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Product variants are empty'**
  String get productDetailVariantsEmpty;

  /// No description provided for @productDetailBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to Case Studies'**
  String get productDetailBackToList;

  /// No description provided for @productDetailMasterpieceCollection.
  ///
  /// In en, this message translates to:
  /// **'MASTERPIECE COLLECTION'**
  String get productDetailMasterpieceCollection;

  /// No description provided for @productDetailBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get productDetailBuyNow;

  /// No description provided for @productScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get productScanTooltip;

  /// No description provided for @productScanRequireLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before scanning'**
  String get productScanRequireLogin;

  /// No description provided for @productScanResult.
  ///
  /// In en, this message translates to:
  /// **'Scan result: {code}'**
  String productScanResult(Object code);

  /// No description provided for @productScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get productScanTitle;

  /// No description provided for @productScanInvalidQrWithContent.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code\\nScanned content: {code}'**
  String productScanInvalidQrWithContent(Object code);

  /// No description provided for @productScanUniqidsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanned products'**
  String get productScanUniqidsListTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @cartSpaceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Space'**
  String get cartSpaceDialogTitle;

  /// No description provided for @cartSpaceDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get cartSpaceDialogHint;

  /// No description provided for @cartAddRequireLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before adding to cart'**
  String get cartAddRequireLogin;

  /// No description provided for @cartConfirmAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get cartConfirmAdd;

  /// No description provided for @cartConfirmChangeSpec.
  ///
  /// In en, this message translates to:
  /// **'Save specification'**
  String get cartConfirmChangeSpec;

  /// No description provided for @cartNoMatchedSku.
  ///
  /// In en, this message translates to:
  /// **'No on-sale SKU matched'**
  String get cartNoMatchedSku;

  /// No description provided for @cartAddBlockedZeroSalesPrice.
  ///
  /// In en, this message translates to:
  /// **'Cannot add to cart when sales price is 0'**
  String get cartAddBlockedZeroSalesPrice;

  /// No description provided for @cartQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get cartQuantityLabel;

  /// No description provided for @cartChangeSpec.
  ///
  /// In en, this message translates to:
  /// **'Change spec'**
  String get cartChangeSpec;

  /// No description provided for @cartSkuDrawerClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get cartSkuDrawerClose;

  /// No description provided for @cartSkuDrawerProductLine.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get cartSkuDrawerProductLine;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart: {title}'**
  String productAddedToCart(Object title);

  /// No description provided for @productAddedToCartSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added to cart! {title}'**
  String productAddedToCartSuccess(Object title);

  /// No description provided for @productAddedToPreOrder.
  ///
  /// In en, this message translates to:
  /// **'Added to pre-order! {title}'**
  String productAddedToPreOrder(Object title);

  /// No description provided for @cartLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cart: {error}'**
  String cartLoadFailed(Object error);

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: \$ {amount}'**
  String cartTotal(Object amount);

  /// No description provided for @webMessageFromHtml.
  ///
  /// In en, this message translates to:
  /// **'Message from Web: {message}'**
  String webMessageFromHtml(Object message);

  /// No description provided for @webNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Web does not support embedded WebView yet. Please use mobile or desktop.'**
  String get webNotSupported;

  /// No description provided for @webViewNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Current platform does not support WebView (or test environment has no platform implementation).'**
  String get webViewNotSupported;

  /// No description provided for @sendMessageToHtml.
  ///
  /// In en, this message translates to:
  /// **'Send Flutter -> HTML message'**
  String get sendMessageToHtml;

  /// No description provided for @flutterMessageCounter.
  ///
  /// In en, this message translates to:
  /// **'Flutter message #{count}'**
  String flutterMessageCounter(int count);

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get commonClearAll;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get commonEdit;

  /// No description provided for @commonEditVerb.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEditVerb;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get commonPreview;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonMinSixChars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get commonMinSixChars;

  /// No description provided for @commonMinSixCharsShort.
  ///
  /// In en, this message translates to:
  /// **'Min 6 chars'**
  String get commonMinSixCharsShort;

  /// No description provided for @commonNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Not match'**
  String get commonNotMatch;

  /// No description provided for @commonDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get commonDepartment;

  /// No description provided for @commonSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get commonSpace;

  /// No description provided for @commonSpaceDefault.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get commonSpaceDefault;

  /// No description provided for @commonUnknownDepartment.
  ///
  /// In en, this message translates to:
  /// **'Unknown Department'**
  String get commonUnknownDepartment;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonActions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get commonActions;

  /// No description provided for @commonLogin.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get commonLogin;

  /// No description provided for @commonPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get commonPrice;

  /// No description provided for @commonUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get commonUnit;

  /// No description provided for @commonModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get commonModel;

  /// No description provided for @commonHot.
  ///
  /// In en, this message translates to:
  /// **'HOT'**
  String get commonHot;

  /// No description provided for @commonProduct.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT:'**
  String get commonProduct;

  /// No description provided for @commonNoProduct.
  ///
  /// In en, this message translates to:
  /// **'no product'**
  String get commonNoProduct;

  /// No description provided for @homeNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavHome;

  /// No description provided for @homeNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeNavProfile;

  /// No description provided for @homeStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Modern Furniture'**
  String get homeStartTitle;

  /// No description provided for @homeStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your room with panto into a lot more minimalist with ease and speed'**
  String get homeStartSubtitle;

  /// No description provided for @homeStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get homeStartShopping;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@firm.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get authPasswordLabel;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully.'**
  String get authLoginSuccess;

  /// No description provided for @cartGoToPreOrder.
  ///
  /// In en, this message translates to:
  /// **'Go To Pre Order'**
  String get cartGoToPreOrder;

  /// No description provided for @cartShoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cartShoppingCart;

  /// No description provided for @cartSummaryTotalNum.
  ///
  /// In en, this message translates to:
  /// **'Total num {count} items'**
  String cartSummaryTotalNum(int count);

  /// No description provided for @cartProjectSummary.
  ///
  /// In en, this message translates to:
  /// **'PROJECT SUMMARY'**
  String get cartProjectSummary;

  /// No description provided for @cartTotalItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'Total items selected'**
  String get cartTotalItemsSelected;

  /// No description provided for @cartEstimatedTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED TOTAL AMOUNT'**
  String get cartEstimatedTotalAmount;

  /// No description provided for @cartPreSubmitOrder.
  ///
  /// In en, this message translates to:
  /// **'Pre Submit Order'**
  String get cartPreSubmitOrder;

  /// No description provided for @cartPreOrder.
  ///
  /// In en, this message translates to:
  /// **'Pre Order'**
  String get cartPreOrder;

  /// No description provided for @cartRemoveLineTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this line?'**
  String get cartRemoveLineTitle;

  /// No description provided for @cartItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ITEMS'**
  String cartItemsCount(int count);

  /// No description provided for @cartSelectSm.
  ///
  /// In en, this message translates to:
  /// **'Select SM'**
  String get cartSelectSm;

  /// No description provided for @cartNoSm.
  ///
  /// In en, this message translates to:
  /// **'No SM'**
  String get cartNoSm;

  /// No description provided for @cartSelectSalesRep.
  ///
  /// In en, this message translates to:
  /// **'Select Sales Rep'**
  String get cartSelectSalesRep;

  /// No description provided for @cartNoMatchingSalesRep.
  ///
  /// In en, this message translates to:
  /// **'No matching sales rep'**
  String get cartNoMatchingSalesRep;

  /// No description provided for @cartRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'Please edit content'**
  String get cartRemarkHint;

  /// No description provided for @cartSpaceDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One short tag for this cart line — keeps picks organized.'**
  String get cartSpaceDialogSubtitle;

  /// No description provided for @cartRemoveSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove selected lines?'**
  String get cartRemoveSelectedTitle;

  /// No description provided for @cartClearShortlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear entire shortlist?'**
  String get cartClearShortlistTitle;

  /// No description provided for @cartRemoveSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} selected lines will be removed from your shortlist.'**
  String cartRemoveSelectedMessage(int count);

  /// No description provided for @cartClearShortlistMessage.
  ///
  /// In en, this message translates to:
  /// **'This clears all cart lines currently loaded for your sites.'**
  String get cartClearShortlistMessage;

  /// No description provided for @cartSelectedLinesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Selected lines removed'**
  String get cartSelectedLinesRemoved;

  /// No description provided for @cartShortlistCleared.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared'**
  String get cartShortlistCleared;

  /// No description provided for @cartRemoveSelectedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove selected lines. Please try again.'**
  String get cartRemoveSelectedFailed;

  /// No description provided for @cartClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cart. Please try again.'**
  String get cartClearFailed;

  /// No description provided for @cartExportQuotation.
  ///
  /// In en, this message translates to:
  /// **'Export Quotation'**
  String get cartExportQuotation;

  /// No description provided for @preOrderLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Pre order load failed: {error}'**
  String preOrderLoadFailed(Object error);

  /// No description provided for @preOrderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pre-order items'**
  String get preOrderEmpty;

  /// No description provided for @preOrderTotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total: '**
  String get preOrderTotalPrefix;

  /// No description provided for @preOrderTotalSuffix.
  ///
  /// In en, this message translates to:
  /// **' items'**
  String get preOrderTotalSuffix;

  /// No description provided for @preOrderGoToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Go To Checkout'**
  String get preOrderGoToCheckout;

  /// No description provided for @preOrderExportConfigEmpty.
  ///
  /// In en, this message translates to:
  /// **'Export form config is empty.'**
  String get preOrderExportConfigEmpty;

  /// No description provided for @preOrderQuotationExported.
  ///
  /// In en, this message translates to:
  /// **'Quotation exported'**
  String get preOrderQuotationExported;

  /// No description provided for @preOrderExportSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'File: {fileName}\n\nSaved to:\n{filePath}'**
  String preOrderExportSavedMessage(Object fileName, Object filePath);

  /// No description provided for @preOrderCheckoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed'**
  String get preOrderCheckoutFailed;

  /// No description provided for @preOrderOrderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get preOrderOrderCreated;

  /// No description provided for @preOrderQuotationPreview.
  ///
  /// In en, this message translates to:
  /// **'Quotation Preview'**
  String get preOrderQuotationPreview;

  /// No description provided for @preOrderPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview is not available on this device.'**
  String get preOrderPreviewUnavailable;

  /// No description provided for @productTechnicalData.
  ///
  /// In en, this message translates to:
  /// **'Technical Data'**
  String get productTechnicalData;

  /// No description provided for @productRefCode.
  ///
  /// In en, this message translates to:
  /// **'Ref. {code}'**
  String productRefCode(Object code);

  /// No description provided for @productSortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get productSortDefault;

  /// No description provided for @productSortPriceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price(Low > High)'**
  String get productSortPriceLowHigh;

  /// No description provided for @productSortPriceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price(Low < High)'**
  String get productSortPriceHighLow;

  /// No description provided for @productSortRatingHighest.
  ///
  /// In en, this message translates to:
  /// **'Rating(Highest)'**
  String get productSortRatingHighest;

  /// No description provided for @productSortRatingLowest.
  ///
  /// In en, this message translates to:
  /// **'Rating(Lowest)'**
  String get productSortRatingLowest;

  /// No description provided for @productSortModelAz.
  ///
  /// In en, this message translates to:
  /// **'Model(A - Z)'**
  String get productSortModelAz;

  /// No description provided for @productSortModelZa.
  ///
  /// In en, this message translates to:
  /// **'Model(Z - A)'**
  String get productSortModelZa;

  /// No description provided for @productSortDateOldNew.
  ///
  /// In en, this message translates to:
  /// **'Date Added(Old >New)'**
  String get productSortDateOldNew;

  /// No description provided for @productSortDateNewOld.
  ///
  /// In en, this message translates to:
  /// **'Date Added(New >Old)'**
  String get productSortDateNewOld;

  /// No description provided for @productExpandFilterSidebar.
  ///
  /// In en, this message translates to:
  /// **'Expand filter sidebar'**
  String get productExpandFilterSidebar;

  /// No description provided for @productSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by: {label}'**
  String productSortBy(Object label);

  /// No description provided for @productInShowroom.
  ///
  /// In en, this message translates to:
  /// **'In Showroom'**
  String get productInShowroom;

  /// No description provided for @productSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Please'**
  String get productSearchHint;

  /// No description provided for @productClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get productClearSearch;

  /// No description provided for @productLibrary.
  ///
  /// In en, this message translates to:
  /// **'Product Library'**
  String get productLibrary;

  /// No description provided for @productFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get productFilters;

  /// No description provided for @productCategories.
  ///
  /// In en, this message translates to:
  /// **'Product Categories'**
  String get productCategories;

  /// No description provided for @productNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get productNoCategories;

  /// No description provided for @profileSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully.'**
  String get profileSettingsUpdated;

  /// No description provided for @profileSwitchedToMainAccount.
  ///
  /// In en, this message translates to:
  /// **'Switched to main account.'**
  String get profileSwitchedToMainAccount;

  /// No description provided for @profileAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profileAccountSettings;

  /// No description provided for @profilePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInformation;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get profileFullNameLabel;

  /// No description provided for @profileOldPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'OLD PASSWORD'**
  String get profileOldPasswordLabel;

  /// No description provided for @profileNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get profileNewPasswordLabel;

  /// No description provided for @profileConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get profileConfirmPasswordLabel;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @profileOtherSettings.
  ///
  /// In en, this message translates to:
  /// **'Another Settings'**
  String get profileOtherSettings;

  /// No description provided for @profileSwitchSiteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch site'**
  String get profileSwitchSiteTooltip;

  /// No description provided for @profileSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Manage your active session and sign-in account.'**
  String get profileSessionHint;

  /// No description provided for @profileSwitchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get profileSwitchAccount;

  /// No description provided for @profileSwitchAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch back to original account'**
  String get profileSwitchAccountSubtitle;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exit current account'**
  String get profileSignOutSubtitle;

  /// No description provided for @profileSettingsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get profileSettingsNameRequired;

  /// No description provided for @profileSettingsPasswordFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please complete all password fields.'**
  String get profileSettingsPasswordFieldsRequired;

  /// No description provided for @profileSettingsPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get profileSettingsPasswordMinLength;

  /// No description provided for @profileSettingsPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New Password and Confirm Password must match.'**
  String get profileSettingsPasswordMismatch;

  /// No description provided for @profileSectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'{title} is empty'**
  String profileSectionEmpty(Object title);

  /// No description provided for @profileUid.
  ///
  /// In en, this message translates to:
  /// **'UID: {id}'**
  String profileUid(Object id);

  /// No description provided for @profileSiteId.
  ///
  /// In en, this message translates to:
  /// **'SITEID: {id}'**
  String profileSiteId(Object id);

  /// No description provided for @profileFavNum.
  ///
  /// In en, this message translates to:
  /// **'FAV NUM'**
  String get profileFavNum;

  /// No description provided for @profileCartNum.
  ///
  /// In en, this message translates to:
  /// **'CART NUM'**
  String get profileCartNum;

  /// No description provided for @profileAccountPreferences.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT & PREFERENCES'**
  String get profileAccountPreferences;

  /// No description provided for @profileAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get profileAddCustomer;

  /// No description provided for @profileSetCommandPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Command Password'**
  String get profileSetCommandPassword;

  /// No description provided for @profileBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to list'**
  String get profileBackToList;

  /// No description provided for @profileFavoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Favorites is empty'**
  String get profileFavoritesEmpty;

  /// No description provided for @profileLoggedInAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Logged in as customer.'**
  String get profileLoggedInAsCustomer;

  /// No description provided for @profileCustomerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get profileCustomerDeleted;

  /// No description provided for @profileNoCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers'**
  String get profileNoCustomers;

  /// No description provided for @profileCustomerName.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER NAME'**
  String get profileCustomerName;

  /// No description provided for @profileUidHeader.
  ///
  /// In en, this message translates to:
  /// **'UID'**
  String get profileUidHeader;

  /// No description provided for @profileDeleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete customer'**
  String get profileDeleteCustomer;

  /// No description provided for @profileDeleteCustomerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} ({username})?'**
  String profileDeleteCustomerConfirm(Object name, Object username);

  /// No description provided for @profileOrderTabMy.
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get profileOrderTabMy;

  /// No description provided for @profileOrderTabCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get profileOrderTabCustomer;

  /// No description provided for @profileNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get profileNoOrders;

  /// No description provided for @profileOrderStatusSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get profileOrderStatusSuccessful;

  /// No description provided for @profileOrderStatusFail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get profileOrderStatusFail;

  /// No description provided for @profileOrderSendToErp.
  ///
  /// In en, this message translates to:
  /// **'Send to ERP'**
  String get profileOrderSendToErp;

  /// No description provided for @profileOrderNotSentToErp.
  ///
  /// In en, this message translates to:
  /// **'Not sent to ERP'**
  String get profileOrderNotSentToErp;

  /// No description provided for @profileOrderNoLabel.
  ///
  /// In en, this message translates to:
  /// **'OrderNo:'**
  String get profileOrderNoLabel;

  /// No description provided for @profileOrderTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String profileOrderTime(Object time);

  /// No description provided for @profileMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileMenuSettings;

  /// No description provided for @profileMenuMyCustomers.
  ///
  /// In en, this message translates to:
  /// **'My Customers'**
  String get profileMenuMyCustomers;

  /// No description provided for @profileMenuOrderCenter.
  ///
  /// In en, this message translates to:
  /// **'Order Center'**
  String get profileMenuOrderCenter;

  /// No description provided for @profileMenuFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileMenuFavorites;

  /// No description provided for @profileCustomerNew.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get profileCustomerNew;

  /// No description provided for @profileCustomerEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get profileCustomerEdit;

  /// No description provided for @profileCustomerUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username or Email is required.'**
  String get profileCustomerUsernameRequired;

  /// No description provided for @profileCustomerPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get profileCustomerPasswordMinLength;

  /// No description provided for @profileCustomerUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'USERNAME OR EMAIL'**
  String get profileCustomerUsernameLabel;

  /// No description provided for @profileCustomerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get profileCustomerPasswordLabel;

  /// No description provided for @profileCustomerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get profileCustomerNameLabel;

  /// No description provided for @profileCustomerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'PHONE'**
  String get profileCustomerPhoneLabel;

  /// No description provided for @profileCustomerUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Login identifier for this customer account.'**
  String get profileCustomerUsernameHint;

  /// No description provided for @profileCustomerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Required for create and update (min 6 characters).'**
  String get profileCustomerPasswordHint;

  /// No description provided for @profileCustomerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Display name.'**
  String get profileCustomerNameHint;

  /// No description provided for @profileCustomerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Contact telephone.'**
  String get profileCustomerPhoneHint;

  /// No description provided for @profileCommandPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Command Password'**
  String get profileCommandPasswordTitle;

  /// No description provided for @profileCommandPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Applies as the shared customer account password for this store.'**
  String get profileCommandPasswordHint;

  /// No description provided for @profileSwitchSiteTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch site'**
  String get profileSwitchSiteTitle;

  /// No description provided for @profileNoSites.
  ///
  /// In en, this message translates to:
  /// **'No sites available.'**
  String get profileNoSites;

  /// No description provided for @profileSiteFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Site #{id}'**
  String profileSiteFallbackTitle(int id);

  /// No description provided for @profileSiteCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current site · ID: {id}'**
  String profileSiteCurrent(int id);

  /// No description provided for @profileSiteIdLine.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String profileSiteIdLine(int id);

  /// No description provided for @sessionEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get sessionEndedTitle;

  /// No description provided for @sessionEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue shopping.'**
  String get sessionEndedMessage;

  /// No description provided for @sessionEndedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get sessionEndedSignIn;

  /// No description provided for @errorMissingCompanyId.
  ///
  /// In en, this message translates to:
  /// **'Missing company id'**
  String get errorMissingCompanyId;

  /// No description provided for @errorMissingToken.
  ///
  /// In en, this message translates to:
  /// **'Missing token'**
  String get errorMissingToken;

  /// No description provided for @errorInvalidProductResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid product response format'**
  String get errorInvalidProductResponseFormat;

  /// No description provided for @errorInvalidProductsListFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid products list format'**
  String get errorInvalidProductsListFormat;

  /// No description provided for @errorInvalidFavoritesResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid favorites response format'**
  String get errorInvalidFavoritesResponseFormat;

  /// No description provided for @errorInvalidFavoritesListFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid favorites list format'**
  String get errorInvalidFavoritesListFormat;

  /// No description provided for @errorInvalidCategoryTreeResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid category tree response format'**
  String get errorInvalidCategoryTreeResponseFormat;

  /// No description provided for @errorInvalidProductDetailResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid product detail response format'**
  String get errorInvalidProductDetailResponseFormat;

  /// No description provided for @errorInvalidCartNumResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid cart num response format'**
  String get errorInvalidCartNumResponseFormat;

  /// No description provided for @errorCartNumRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Cart num request failed'**
  String get errorCartNumRequestFailed;

  /// No description provided for @errorMissingCartNumResult.
  ///
  /// In en, this message translates to:
  /// **'Missing result in cart num response'**
  String get errorMissingCartNumResult;

  /// No description provided for @errorInvalidCartListResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid cart list response format'**
  String get errorInvalidCartListResponseFormat;

  /// No description provided for @errorUpdateCartSelectedFailed.
  ///
  /// In en, this message translates to:
  /// **'Update cart selected failed'**
  String get errorUpdateCartSelectedFailed;

  /// No description provided for @errorUpdateRemarkFailed.
  ///
  /// In en, this message translates to:
  /// **'Update remark failed'**
  String get errorUpdateRemarkFailed;

  /// No description provided for @errorChangeCartQuantityFailed.
  ///
  /// In en, this message translates to:
  /// **'Change cart quantity failed'**
  String get errorChangeCartQuantityFailed;

  /// No description provided for @errorDeleteCartItemFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete cart item failed'**
  String get errorDeleteCartItemFailed;

  /// No description provided for @errorCreateOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Create order failed'**
  String get errorCreateOrderFailed;

  /// No description provided for @errorPleaseSelectSm.
  ///
  /// In en, this message translates to:
  /// **'Please select SM ({label})'**
  String errorPleaseSelectSm(Object label);

  /// No description provided for @errorNoSalesRepSelections.
  ///
  /// In en, this message translates to:
  /// **'No sales rep selections to submit.'**
  String get errorNoSalesRepSelections;

  /// No description provided for @errorSetSmFailed.
  ///
  /// In en, this message translates to:
  /// **'Set SM failed'**
  String get errorSetSmFailed;

  /// No description provided for @errorInvalidSmSelection.
  ///
  /// In en, this message translates to:
  /// **'Invalid SM selection.'**
  String get errorInvalidSmSelection;

  /// No description provided for @errorAddToCartFailed.
  ///
  /// In en, this message translates to:
  /// **'Add to cart failed'**
  String get errorAddToCartFailed;

  /// No description provided for @errorInvalidQuotationConfigResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid quotation config response format'**
  String get errorInvalidQuotationConfigResponseFormat;

  /// No description provided for @errorExportQuotationResponseEmpty.
  ///
  /// In en, this message translates to:
  /// **'Export quotation response is empty'**
  String get errorExportQuotationResponseEmpty;

  /// No description provided for @errorExportQuotationFailed.
  ///
  /// In en, this message translates to:
  /// **'Export quotation failed'**
  String get errorExportQuotationFailed;

  /// No description provided for @errorInvalidPreviewResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid preview response format'**
  String get errorInvalidPreviewResponseFormat;

  /// No description provided for @errorPreviewUrlEmpty.
  ///
  /// In en, this message translates to:
  /// **'Preview url is empty'**
  String get errorPreviewUrlEmpty;

  /// No description provided for @errorInvalidUserInfoResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid user info response format'**
  String get errorInvalidUserInfoResponseFormat;

  /// No description provided for @errorUpdateUserInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Update user info failed'**
  String get errorUpdateUserInfoFailed;

  /// No description provided for @errorInvalidOrderListResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid order list response format'**
  String get errorInvalidOrderListResponseFormat;

  /// No description provided for @errorInvalidCustomerListResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid customer list response'**
  String get errorInvalidCustomerListResponse;

  /// No description provided for @errorCreateCustomerFailed.
  ///
  /// In en, this message translates to:
  /// **'Create customer failed'**
  String get errorCreateCustomerFailed;

  /// No description provided for @errorUpdateCustomerFailed.
  ///
  /// In en, this message translates to:
  /// **'Update customer failed'**
  String get errorUpdateCustomerFailed;

  /// No description provided for @errorResetCommonPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset common password failed'**
  String get errorResetCommonPasswordFailed;

  /// No description provided for @errorDeleteCustomerFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete customer failed'**
  String get errorDeleteCustomerFailed;

  /// No description provided for @errorInvalidCustomerLoginResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid customer login response'**
  String get errorInvalidCustomerLoginResponse;

  /// No description provided for @errorInvalidCompanyListResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid company list response'**
  String get errorInvalidCompanyListResponse;

  /// No description provided for @errorMissingItemsInCompanyList.
  ///
  /// In en, this message translates to:
  /// **'Missing items in company list'**
  String get errorMissingItemsInCompanyList;

  /// No description provided for @errorInvalidSwitchShopResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid switch shop response'**
  String get errorInvalidSwitchShopResponse;

  /// No description provided for @errorMissingCompanyIdInSwitchResponse.
  ///
  /// In en, this message translates to:
  /// **'Missing company_id in switch response'**
  String get errorMissingCompanyIdInSwitchResponse;

  /// No description provided for @errorMissingTokenInSwitchResponse.
  ///
  /// In en, this message translates to:
  /// **'Missing token in switch response'**
  String get errorMissingTokenInSwitchResponse;

  /// No description provided for @errorLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get errorLogoutFailed;

  /// No description provided for @errorLogoutRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout request failed'**
  String get errorLogoutRequestFailed;

  /// No description provided for @errorInvalidLoginResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid login response format'**
  String get errorInvalidLoginResponseFormat;

  /// No description provided for @errorInvalidCompanyIdInLoginResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid company_id in login response'**
  String get errorInvalidCompanyIdInLoginResponse;

  /// No description provided for @errorInvalidRegisterResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid register response format'**
  String get errorInvalidRegisterResponseFormat;

  /// No description provided for @errorInvalidCompanyIdInRegisterResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid company_id in register response'**
  String get errorInvalidCompanyIdInRegisterResponse;

  /// No description provided for @errorRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get errorRequestFailed;

  /// No description provided for @errorNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get errorNetworkError;

  /// No description provided for @errorSessionExpiredDefault.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpiredDefault;

  /// No description provided for @errorPleaseSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first.'**
  String get errorPleaseSignInFirst;

  /// No description provided for @errorInvalidProductQuantity.
  ///
  /// In en, this message translates to:
  /// **'Invalid product quantity.'**
  String get errorInvalidProductQuantity;

  /// No description provided for @errorCreateFavoriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Create favorite failed'**
  String get errorCreateFavoriteFailed;

  /// No description provided for @errorDeleteFavoriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete favorite failed'**
  String get errorDeleteFavoriteFailed;

  /// No description provided for @errorFetchSiteInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch site info failed'**
  String get errorFetchSiteInfoFailed;

  /// No description provided for @errorInvalidUserPayloadAfterSwitch.
  ///
  /// In en, this message translates to:
  /// **'Invalid user payload after switch'**
  String get errorInvalidUserPayloadAfterSwitch;

  /// No description provided for @errorUserInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'User info missing'**
  String get errorUserInfoMissing;

  /// No description provided for @errorInvalidCustomerSession.
  ///
  /// In en, this message translates to:
  /// **'Invalid customer session'**
  String get errorInvalidCustomerSession;

  /// No description provided for @errorNoMainAccountToSwitch.
  ///
  /// In en, this message translates to:
  /// **'No main account to switch'**
  String get errorNoMainAccountToSwitch;

  /// No description provided for @errorInvalidMainAccountSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Invalid main account snapshot'**
  String get errorInvalidMainAccountSnapshot;

  /// No description provided for @cartUnorderedNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get cartUnorderedNoticeTitle;

  /// No description provided for @cartUnorderedItemsDefault.
  ///
  /// In en, this message translates to:
  /// **'There are still unordered items in the shopping cart.'**
  String get cartUnorderedItemsDefault;

  /// No description provided for @cartGoToCart.
  ///
  /// In en, this message translates to:
  /// **'Go to Cart'**
  String get cartGoToCart;

  /// No description provided for @toastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get toastSuccess;

  /// No description provided for @toastInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get toastInfo;

  /// No description provided for @toastWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get toastWarning;

  /// No description provided for @toastError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get toastError;

  /// No description provided for @debugSecureStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Storage Debug'**
  String get debugSecureStorageTitle;

  /// No description provided for @debugRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get debugRefresh;

  /// No description provided for @debugMaskValues.
  ///
  /// In en, this message translates to:
  /// **'Mask stored values'**
  String get debugMaskValues;

  /// No description provided for @debugMaskValuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off to show full plaintext'**
  String get debugMaskValuesSubtitle;

  /// No description provided for @debugClearAllKeys.
  ///
  /// In en, this message translates to:
  /// **'Clear all keys'**
  String get debugClearAllKeys;

  /// No description provided for @debugNoStorageContent.
  ///
  /// In en, this message translates to:
  /// **'No stored content yet'**
  String get debugNoStorageContent;

  /// No description provided for @debugDeleteKey.
  ///
  /// In en, this message translates to:
  /// **'Delete this key'**
  String get debugDeleteKey;

  /// No description provided for @debugLocalOnlyWarning.
  ///
  /// In en, this message translates to:
  /// **'For local debugging only. Do not ship this page entry in production.'**
  String get debugLocalOnlyWarning;

  /// No description provided for @debugLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}'**
  String debugLoadFailed(String error);

  /// No description provided for @debugEmptyStringPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(empty string)'**
  String get debugEmptyStringPlaceholder;

  /// No description provided for @errorCustomerLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Customer login failed'**
  String get errorCustomerLoginFailed;

  /// No description provided for @errorFetchProductsFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch products failed'**
  String get errorFetchProductsFailed;

  /// No description provided for @errorFetchFavoritesFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch favorites failed'**
  String get errorFetchFavoritesFailed;

  /// No description provided for @errorFetchCategoryTreeFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch category tree failed'**
  String get errorFetchCategoryTreeFailed;

  /// No description provided for @errorFetchProductDetailFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch product detail failed'**
  String get errorFetchProductDetailFailed;

  /// No description provided for @errorFetchCartNumFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch cart num failed'**
  String get errorFetchCartNumFailed;

  /// No description provided for @errorFetchCartListFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch cart list failed'**
  String get errorFetchCartListFailed;

  /// No description provided for @errorClearCartFailed.
  ///
  /// In en, this message translates to:
  /// **'Clear cart failed'**
  String get errorClearCartFailed;

  /// No description provided for @errorChangeCartSpecFailed.
  ///
  /// In en, this message translates to:
  /// **'Change cart spec failed'**
  String get errorChangeCartSpecFailed;

  /// No description provided for @errorQuotationConfigRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Quotation config request failed'**
  String get errorQuotationConfigRequestFailed;

  /// No description provided for @errorFetchQuotationConfigFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch quotation config failed'**
  String get errorFetchQuotationConfigFailed;

  /// No description provided for @errorPreviewQuotationFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview quotation failed'**
  String get errorPreviewQuotationFailed;

  /// No description provided for @errorFetchUserInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch user info failed'**
  String get errorFetchUserInfoFailed;

  /// No description provided for @errorFetchOrderListFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch order list failed'**
  String get errorFetchOrderListFailed;

  /// No description provided for @errorLoginRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Login request failed'**
  String get errorLoginRequestFailed;

  /// No description provided for @errorCartNotReady.
  ///
  /// In en, this message translates to:
  /// **'Cart not ready.'**
  String get errorCartNotReady;

  /// No description provided for @errorFetchCustomersFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch customers failed'**
  String get errorFetchCustomersFailed;

  /// No description provided for @errorFetchCompanyListFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch company list failed'**
  String get errorFetchCompanyListFailed;

  /// No description provided for @errorRegisterRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Register request failed'**
  String get errorRegisterRequestFailed;

  /// No description provided for @errorSwitchShopFailed.
  ///
  /// In en, this message translates to:
  /// **'Switch shop failed'**
  String get errorSwitchShopFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
