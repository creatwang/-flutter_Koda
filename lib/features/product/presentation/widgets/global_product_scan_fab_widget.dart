import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/features/product/controllers/product_detail_controller.dart';
import 'package:george_pick_mate/features/product/presentation/pages/qr_scan_page.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/draggable_scan_fab.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_scan_result_dialog_widget.dart';
import 'package:george_pick_mate/features/product/services/product_sku_cart_helpers.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';

class GlobalProductScanFabWidget extends ConsumerStatefulWidget {
  const GlobalProductScanFabWidget({
    required this.bottomOffset,
    super.key,
  });

  final double bottomOffset;

  @override
  ConsumerState<GlobalProductScanFabWidget> createState() =>
      _GlobalProductScanFabWidgetState();
}

class _GlobalProductScanFabWidgetState
    extends ConsumerState<GlobalProductScanFabWidget> {
  Future<void> _onScanQrTap() async {
    final session = ref.read(sessionControllerProvider).asData?.value;
    if (session?.isAuthenticated != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productScanRequireLogin)),
      );
      context.go(AppRoutes.login);
      return;
    }

    final navigatorState = appNavigatorKey.currentState;
    if (navigatorState == null) return;
    final code = await navigatorState.push<String>(
      MaterialPageRoute<String>(builder: (_) => const QrScanPage()),
    );
    if (!mounted || code == null || code.trim().isEmpty) return;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

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
        pageBuilder: (
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
      if (loadingRouteShown && mounted) {
        navigatorState.pop();
      }
    }

    if (!mounted) return;
    if (loadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productDetailLoadFailed('$loadError'))),
      );
      return;
    }
    if (scanResult == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.cartNoMatchedSku)));
      return;
    }
    final resultDialogContext = appNavigatorKey.currentContext;
    if (resultDialogContext == null) return;
    final added = await showProductScanResultDialog(
      // ignore: use_build_context_synchronously
      context: resultDialogContext,
      detail: scanResult.detail,
      selected: scanResult.selected,
      selectedSub: scanResult.selectedSub,
      skuRowSelection: scanResult.skuRowSelection,
      onAddToCart: (dialogContext) => _addScannedSkuToCart(
        dialogContext,
        scanResult!,
      ),
    );
    if (!mounted || !added) return;
    final title = scanResult.selected.name ?? scanResult.detail.name ?? '--';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.productAddedToCart(title))),
    );
  }

  Future<bool> _addScannedSkuToCart(
    BuildContext dialogContext,
    ProductDetailScanResult scanResult,
  ) async {
    final sub = scanResult.selectedSub;
    final productId = sub.pid;
    if (productId == null) return false;
    final subIndex = ProductSkuCartHelpers.subIndexForApi(sub);
    if (subIndex.isEmpty) return false;
    final subName = ProductSkuCartHelpers.buildCartSubName(
      sub: sub,
      skuRowSelection: scanResult.skuRowSelection,
    );
    final space = await resolveSpaceForCartAdd(dialogContext);
    if (space == null) return false;
    return ref.read(cartControllerProvider.notifier).createCartItem(
      productId: productId,
      subIndex: subIndex,
      productNum: 1,
      space: space,
      subName: subName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: DraggableScanFab(
          initialBottomOffset: widget.bottomOffset,
          onTap: _onScanQrTap,
        ),
      ),
    );
  }
}
