import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/services/cart_create_flow_services.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/features/product/controllers/product_detail_controller.dart';
import 'package:george_pick_mate/features/product/presentation/pages/qr_scan_page.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_scan_result_dialog_widget.dart';
import 'package:george_pick_mate/features/product/services/product_scan_services.dart';
import 'package:george_pick_mate/features/product/services/product_sku_cart_helpers.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';

/// 商品扫码入口流程（会话检查、扫码页、解析 id、跳转详情）。
Future<void> runProductQrScanFlow({
  required WidgetRef ref,
  required BuildContext context,
}) async {
  final session = ref.read(sessionControllerProvider).asData?.value;
  if (session?.isAuthenticated != true) {
    if (!context.mounted) return;
    showGlobalWarningMessage(
      context.l10n.productScanRequireLogin,
      context: context,
    );
    context.go(AppRoutes.login);
    return;
  }

  final navigatorState = appNavigatorKey.currentState;
  if (navigatorState == null) return;
  final code = await navigatorState.push<String>(
    MaterialPageRoute<String>(builder: (_) => const QrScanPage()),
  );
  if (!context.mounted || code == null || code.trim().isEmpty) return;

  final scanned = code.trim();
  final productId = ProductScanServices.resolveProductIdFromScan(scanned);
  if (productId == null) {
    showGlobalWarningMessage(
      context.l10n.productScanInvalidQrWithContent(scanned),
      context: context,
    );
    return;
  }
  context.push(AppRoutes.productDetail(productId));
}

// Legacy note:
// 保留旧版“扫码后自动解析 SKU 并弹窗加购”实现，当前版本先切换为
// “扫码直达商品详情页”。后续版本如需恢复旧流程，可重新接入此方法。
//
// ignore: unused_element
Future<void> _runLegacyProductQrScanFlow({
  required WidgetRef ref,
  required BuildContext context,
  required String code,
}) async {
  final navigatorState = appNavigatorKey.currentState;
  if (navigatorState == null) return;

  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return;

  ProductDetailScanResult? scanResult;
  Object? loadError;
  var loadingRouteShown = false;
  try {
    final dialogContext = appNavigatorKey.currentContext;
    if (dialogContext == null) return;
    showGeneralDialog<void>(
      // ignore: use_build_context_synchronously
      context: dialogContext,
      barrierDismissible: false,
      barrierLabel:
          // ignore: use_build_context_synchronously
          MaterialLocalizations.of(dialogContext).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      useRootNavigator: true,
      pageBuilder:
          (
            BuildContext overlayContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            final scheme = Theme.of(overlayContext).colorScheme;
            return PopScope(
              canPop: false,
              child: SizedBox.expand(
                child: Material(
                  type: MaterialType.transparency,
                  child: ColoredBox(
                    color: scheme.scrim.withValues(alpha: 0.65),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            overlayContext.l10n.commonLoading,
                            style: Theme.of(overlayContext).textTheme.bodyLarge
                                ?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
    );
    loadingRouteShown = true;
    await WidgetsBinding.instance.endOfFrame;

    scanResult = await ProductDetailController.formatProductDetailScanInfo(
      code,
    );
  } catch (e) {
    loadError = e;
  } finally {
    if (loadingRouteShown && context.mounted) {
      navigatorState.pop();
    }
  }

  if (!context.mounted) return;
  if (loadError != null) {
    showGlobalErrorMessage(context.l10n.productDetailLoadFailed('$loadError'));
    return;
  }
  if (scanResult == null) {
    showGlobalWarningMessage(context.l10n.cartNoMatchedSku, context: context);
    return;
  }
  final resultDialogContext = appNavigatorKey.currentContext;
  if (resultDialogContext == null) return;
  int? submittedSmId;
  final added = await showProductScanResultDialog(
    // ignore: use_build_context_synchronously
    context: resultDialogContext,
    detail: scanResult.detail,
    selected: scanResult.selected,
    selectedSub: scanResult.selectedSub,
    skuRowSelection: scanResult.skuRowSelection,
    onAddToCart: (dialogContext) async {
      submittedSmId = await _addScannedSkuToCart(
        ref,
        dialogContext,
        scanResult!,
      );
      return submittedSmId != null;
    },
  );
  if (!context.mounted || !added || submittedSmId == null) return;
  final title = scanResult.selected.name ?? scanResult.detail.name ?? '--';
  showGlobalSnackBar(
    buildAddToCartSuccessMessage(
      l10n: context.l10n,
      productTitle: title,
      smId: submittedSmId!,
    ),
  );
}

Future<int?> _addScannedSkuToCart(
  WidgetRef ref,
  BuildContext dialogContext,
  ProductDetailScanResult scanResult,
) async {
  final sub = scanResult.selectedSub;
  final productId = sub.pid;
  if (productId == null) return null;
  final subIndex = ProductSkuCartHelpers.subIndexForApi(sub);
  if (subIndex.isEmpty) return null;
  final sIndex = ProductSkuCartHelpers.sIndexForApi(sub);
  final subName = ProductSkuCartHelpers.buildCartSubName(
    sub: sub,
    skuRowSelection: scanResult.skuRowSelection,
  );
  final space = await resolveSpaceForCartAdd(dialogContext);
  if (space == null) return null;
  final result = await ref
      .read(cartControllerProvider.notifier)
      .createCartItem(
        productId: productId,
        subIndex: subIndex,
        sIndex: sIndex,
        productNum: 1,
        space: space,
        subName: subName,
      );
  return resolveCreateCartItemSubmitSuccess(result);
}
