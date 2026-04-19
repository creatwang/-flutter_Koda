import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/auth/controllers/store_company_providers.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 底部弹出：可选站点列表并调用 [SessionController.switchShop]。
///
/// [parentContext]：发起页的 [BuildContext]，用于成功后 [GoRouter.go] 到首页。
Future<void> showSwitchSiteBottomSheet({
  required BuildContext parentContext,
  required WidgetRef ref,
}) {
  ref.invalidate(storeCompanyListProvider);
  return showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext _) {
      return _SwitchSiteSheetScaffold(parentContext: parentContext);
    },
  );
}

class _SwitchSiteSheetScaffold extends ConsumerStatefulWidget {
  const _SwitchSiteSheetScaffold({required this.parentContext});

  /// 设置页等外层上下文，用于关闭弹层后导航。
  final BuildContext parentContext;

  @override
  ConsumerState<_SwitchSiteSheetScaffold> createState() =>
      _SwitchSiteSheetScaffoldState();
}

class _SwitchSiteSheetScaffoldState extends ConsumerState<_SwitchSiteSheetScaffold> {
  /// 正在切换的站点 id；非空时禁用其它行点击。
  int? _busySiteId;

  static int? _idFromItem(Map<String, dynamic> item) {
    final dynamic v = item['id'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  Future<void> _pickSite(int id) async {
    setState(() => _busySiteId = id);
    final messenger = ScaffoldMessenger.maybeOf(widget.parentContext);
    final result = await ref
        .read(sessionControllerProvider.notifier)
        .switchShop(companyId: id, shopId: id);
    if (!mounted) return;
    result.when(
      success: (_) {
        Navigator.of(context).pop();
        if (widget.parentContext.mounted) {
          widget.parentContext.go(AppRoutes.home);
        }
      },
      failure: (exception) {
        setState(() => _busySiteId = null);
        messenger?.showSnackBar(
          SnackBar(content: Text(exception.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(storeCompanyListProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final busy = _busySiteId != null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.32,
      maxChildSize: 0.88,
      builder: (BuildContext _, ScrollController scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1D24),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            border: Border(
              top: BorderSide(color: Color(0x44FFFFFF)),
            ),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Switch site',
                    style: TextStyle(
                      color: ProMaxTokens.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: async.when(
                  data: (List<Map<String, dynamic>> items) {
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No sites available.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0x22FFFFFF)),
                      itemBuilder: (BuildContext _, int index) {
                        final item = items[index];
                        final title =
                            item['title']?.toString() ??
                            item['name']?.toString() ??
                            '';
                        final id = _idFromItem(item);
                        final isRowBusy = id != null && _busySiteId == id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          title: Text(
                            title.isEmpty ? 'Site #$id' : title,
                            style: TextStyle(
                              color: ProMaxTokens.textPrimary.withValues(
                                alpha: busy && !isRowBusy ? 0.45 : 1,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: id == null
                              ? null
                              : Text(
                                  'ID: $id',
                                  style: TextStyle(
                                    color: ProMaxTokens.textSecondary
                                        .withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                ),
                          trailing: isRowBusy
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Color(0xFFF4C77A),
                                  ),
                                )
                              : Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                          onTap: id == null || busy
                              ? null
                              : () => _pickSite(id),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (Object e, StackTrace _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SelectableText.rich(
                        TextSpan(
                          text: e.toString(),
                          style: const TextStyle(
                            color: Color(0xFFFF8A8A),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
