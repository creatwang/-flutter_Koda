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

/// 业务员客户列表：表头、列表行（代客登录等逻辑不变）。
class ProfileMyCustomersSectionWidget extends ConsumerStatefulWidget {
  const ProfileMyCustomersSectionWidget({super.key});

  @override
  ConsumerState<ProfileMyCustomersSectionWidget> createState() =>
      _ProfileMyCustomersSectionWidgetState();
}

class _ProfileMyCustomersSectionWidgetState
    extends ConsumerState<ProfileMyCustomersSectionWidget> {
  /// 正在代客登录的客户行 `id`；非空时禁止重复点击。
  int? _loggingInCustomerId;

  Future<void> _refresh() async {
    await ref.read(storeCustomersProvider.notifier).refresh();
  }

  void _loadMore() {
    ref.read(storeCustomersProvider.notifier).loadMore();
  }

  Future<void> _onLogin(StoreCustomerItemDto item) async {
    if (_loggingInCustomerId != null) return;
    setState(() => _loggingInCustomerId = item.id);
    try {
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        },
      );
    } finally {
      if (mounted) setState(() => _loggingInCustomerId = null);
    }
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
    final result = await ref
        .read(storeCustomersProvider.notifier)
        .deleteCustomer(item);
    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted')));
      },
      failure: (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeCustomersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                  FilledButton(onPressed: _refresh, child: const Text('Retry')),
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
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount:
                        data.items.length + 1 + (data.isLoadingMore ? 1 : 0),
                    itemBuilder: (_, int index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: _MyCustomersTableHeader(),
                        );
                      }
                      final rowIndex = index - 1;
                      if (rowIndex >= data.items.length) {
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
                      final item = data.items[rowIndex];
                      final bool loginBusy = _loggingInCustomerId != null;
                      final bool rowLoginLoading =
                          _loggingInCustomerId == item.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CustomerRowCard(
                          item: item,
                          loginBusy: loginBusy,
                          rowLoginLoading: rowLoginLoading,
                          onEdit: () => showStoreCustomerFormBottomSheet(
                            context: context,
                            ref: ref,
                            mode: StoreCustomerSheetMode.edit,
                            editing: item,
                          ),
                          onDelete: () => _confirmDelete(item),
                          onLogin: () => _onLogin(item),
                        ),
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

/// 设计稿：列表列宽与行内列对齐。
class _MyCustomersColumnLayout {
  _MyCustomersColumnLayout._();

  static const double avatar = 48;
  static const double avatarNameGap = 12;
  /// 与行内「头像 + 间距」占位一致，表头文字与姓名列对齐。
  static const double nameLabelInset = avatar + avatarNameGap;

  static const double uid = 108;
  static const double actions = 132;
  static const double login = 100;
}

String _customerSecondaryLine(StoreCustomerItemDto item) {
  final String e = item.email.trim();
  return e.isNotEmpty ? e : item.username;
}

class _MyCustomersTableHeader extends StatelessWidget {
  const _MyCustomersTableHeader();

  static TextStyle _style() => TextStyle(
    color: ProMaxTokens.textSecondary.withValues(alpha: 0.75),
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: _MyCustomersColumnLayout.nameLabelInset,
                ),
                Expanded(
                  child: Text('CUSTOMER NAME', style: _style()),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _MyCustomersColumnLayout.uid,
            child: Center(child: Text('UID', style: _style())),
          ),
          SizedBox(
            width: _MyCustomersColumnLayout.actions,
            child: Center(child: Text('ACTIONS', style: _style())),
          ),
          SizedBox(
            width: _MyCustomersColumnLayout.login,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('LOGIN', style: _style()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerRowCard extends StatelessWidget {
  const _CustomerRowCard({
    required this.item,
    required this.loginBusy,
    required this.rowLoginLoading,
    required this.onEdit,
    required this.onDelete,
    required this.onLogin,
  });

  final StoreCustomerItemDto item;
  final bool loginBusy;
  final bool rowLoginLoading;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLogin;

  static const Color _uidPillFill = Color(0xFFE8E4DC);
  static const Color _uidPillText = Color(0xFF2A2826);

  @override
  Widget build(BuildContext context) {
    final String secondary = _customerSecondaryLine(item);
    final String? avatarUrl = item.avatar?.trim();
    final bool hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Color.fromRGBO(0, 0, 0, 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: loginBusy ? null : onLogin,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _CustomerAvatar(
                          hasAvatar: hasAvatar,
                          avatarUrl: avatarUrl ?? '',
                          name: item.name,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: ProMaxTokens.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                secondary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ProMaxTokens.textSecondary.withValues(
                                    alpha: 0.92,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: _MyCustomersColumnLayout.uid,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(207, 218, 242, 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            '${item.id}',
                            style: const TextStyle(
                              color: _uidPillText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: _MyCustomersColumnLayout.actions,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: loginBusy ? null : onEdit,
                          style: TextButton.styleFrom(
                            foregroundColor: ProMaxTokens.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Edit'),
                        ),
                        Text(
                          '|',
                          style: TextStyle(
                            color: ProMaxTokens.textSecondary.withValues(
                              alpha: 0.45,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: loginBusy ? null : onDelete,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: _MyCustomersColumnLayout.login,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: loginBusy ? null : onLogin,
                          style: TextButton.styleFrom(
                            foregroundColor: ProMaxTokens.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: rowLoginLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.38),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({
    required this.hasAvatar,
    required this.avatarUrl,
    required this.name,
  });

  final bool hasAvatar;
  final String avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    const double size = _MyCustomersColumnLayout.avatar;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.28),
          child: hasAvatar
              ? Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _AvatarFallback(name: name),
                )
              : _AvatarFallback(name: name),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String letter = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: ProMaxTokens.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
