import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/customer_account_providers.dart';
import 'package:groe_app_pad/features/profile/models/store_customer_item_dto.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/store_customer_form_bottom_sheet.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 业务员客户列表：下拉刷新、分页、增删改、代客登录。
class ProfileMyCustomersSectionWidget extends ConsumerStatefulWidget {
  const ProfileMyCustomersSectionWidget({super.key});

  @override
  ConsumerState<ProfileMyCustomersSectionWidget> createState() =>
      _ProfileMyCustomersSectionWidgetState();
}

class _ProfileMyCustomersSectionWidgetState
    extends ConsumerState<ProfileMyCustomersSectionWidget> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(storeCustomersProvider.notifier).refresh();
  }

  void _loadMore() {
    ref.read(storeCustomersProvider.notifier).loadMore();
  }

  Future<void> _applyKeyword() async {
    await ref.read(storeCustomersProvider.notifier).applyFilters(
          keyword: _keywordController.text.trim(),
        );
  }

  Future<void> _onLogin(StoreCustomerItemDto item) async {
    final result = await ref
        .read(sessionControllerProvider.notifier)
        .loginAsStoreCustomer(customerRowId: item.id);
    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in as customer.')),
        );
        context.go(AppRoutes.home);
      },
      failure: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      },
    );
  }

  Future<void> _confirmDelete(StoreCustomerItemDto item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer'),
        content: Text('Remove ${item.name} (${item.username})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final result =
        await ref.read(storeCustomersProvider.notifier).deleteCustomer(item);
    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted')),
        );
      },
      failure: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeCustomersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _keywordController,
                style: const TextStyle(color: ProMaxTokens.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Keyword',
                  hintStyle: TextStyle(
                    color: ProMaxTokens.textSecondary.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: ProMaxTokens.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _applyKeyword(),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _applyKeyword,
              style: OutlinedButton.styleFrom(
                foregroundColor: ProMaxTokens.textPrimary,
                side: const BorderSide(color: ProMaxTokens.inputBorder),
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Apply'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => showStoreCustomerFormBottomSheet(
                context: context,
                ref: ref,
                mode: StoreCustomerSheetMode.create,
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 44),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: state.when(
            loading: () => const AppLoadingView(),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      text: err.toString(),
                      style: const TextStyle(color: Color(0xFFFF6E76)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (data) {
              if (data.items.isEmpty) {
                return const AppEmptyView(
                  message: 'No customers',
                  width: 120,
                  height: 120,
                );
              }
              return RefreshIndicator(
                onRefresh: _refresh,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels > n.metrics.maxScrollExtent - 320) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      if (index >= data.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final item = data.items[index];
                      return _CustomerRowCard(
                        item: item,
                        onEdit: () => showStoreCustomerFormBottomSheet(
                          context: context,
                          ref: ref,
                          mode: StoreCustomerSheetMode.edit,
                          editing: item,
                        ),
                        onDelete: () => _confirmDelete(item),
                        onLogin: () => _onLogin(item),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomerRowCard extends StatelessWidget {
  const _CustomerRowCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onLogin,
  });

  final StoreCustomerItemDto item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ProMaxTokens.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ProMaxTokens.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: ProMaxTokens.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.username,
                    style: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.telephone,
                    style: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.createdAt,
                    style: TextStyle(
                      color: ProMaxTokens.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextButton(
                  onPressed: onLogin,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
