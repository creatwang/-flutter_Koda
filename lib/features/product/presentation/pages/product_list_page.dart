import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_card.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _ensureLoadScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 300) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  void _ensureScrollableAndLoadMoreIfNeeded() {
    if (_ensureLoadScheduled) return;
    _ensureLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLoadScheduled = false;
      if (!mounted || !_scrollController.hasClients) return;

      final current = ref.read(productsProvider).asData?.value;
      if (current == null || !current.hasMore || current.isLoadingMore) return;

      // 内容不足一屏时（无法滚动到底），主动触发下一页加载。
      if (_scrollController.position.maxScrollExtent <= 0) {
        ref.read(productsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final productsState = ref.watch(productsProvider);
    final columns = context.isTabletUp ? 3 : 2;

    return productsState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(
        message: l10n.productLoadFailed(error.toString()),
        onRetry: () => ref.read(productsProvider.notifier).refresh(),
      ),
      data: (items) {
        if (items.items.isEmpty) return AppEmptyView(message: l10n.productEmpty);
        _ensureScrollableAndLoadMoreIfNeeded();

        return RefreshIndicator(
          onRefresh: () => ref.read(productsProvider.notifier).refresh(),
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: items.items.length + (items.isLoadingMore ? 1 : 0),
            itemBuilder: (_, index) {
              if (index >= items.items.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return ProductCard(productItem: items.items[index]);
            },
          ),
        );
      },
    );
  }
}
