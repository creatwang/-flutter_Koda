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
  /// **'iPad Mall'**
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
