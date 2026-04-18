// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'iPad Mall';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonNoData => 'No data';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLogout => 'Sign out';

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
  String get authRegisterSuccessDemo =>
      'Register demo completed. Please sign in to continue.';

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
  String get commonCancel => 'Cancel';

  @override
  String get addToCart => 'Add to cart';

  @override
  String productAddedToCart(Object title) {
    return 'Added to cart: $title';
  }

  @override
  String cartLoadFailed(Object error) {
    return 'Failed to load cart: $error';
  }

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String cartTotal(Object amount) {
    return 'Total: ¥ $amount';
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
}
