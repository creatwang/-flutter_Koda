import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/product/models/product_category_tree_dto.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/app_error_view.dart';
import 'package:george_pick_mate/shared/widgets/pro_max_glass_card_widget.dart';
import 'package:george_pick_mate/theme/pro_max_tokens.dart';

class ProductFilterPanel extends StatelessWidget {
  const ProductFilterPanel({
    required this.categoryTree,
    required this.onCategoryTreeRetry,
    required this.selectedCategoryId,
    required this.onCategoryTap,
    required this.onCollapseTap,
    required this.pinApplyButtonToBottom,
    super.key,
  });

  final AsyncValue<List<ProductCategoryTreeDto>> categoryTree;
  final VoidCallback onCategoryTreeRetry;
  final int? selectedCategoryId;
  final ValueChanged<ProductCategoryTreeDto> onCategoryTap;
  final VoidCallback? onCollapseTap;
  final bool pinApplyButtonToBottom;

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Product Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ProMaxTokens.textPrimary,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (onCollapseTap != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onCollapseTap,
                  child: Ink(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          color: Colors.white.withValues(alpha: 0.10),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<ProductCategoryTreeDto> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.isEmpty
          ? [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: ProMaxTokens.space3,
                  vertical: ProMaxTokens.space3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  'No categories',
                  style: TextStyle(
                    color: ProMaxTokens.textSecondary.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
          : categories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CategoryTreeNode(
                      category: category,
                      selectedCategoryId: selectedCategoryId,
                      onCategoryTap: onCategoryTap,
                      depth: 0,
                    ),
                  ),
                )
                .toList(growable: false),
    );
  }

  Widget _buildLoadingBody() {
    // 与 Profile Settings（[ProfileContentAreaWidget]）顶栏条一致。
    final bar = LinearProgressIndicator(minHeight: 2);
    if (pinApplyButtonToBottom) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          const Expanded(child: SizedBox.shrink()),
        ],
      );
    }
    return bar;
  }

  @override
  Widget build(BuildContext context) {
    return categoryTree.when(
      skipLoadingOnReload: true,
      loading: () => ProMaxGlassCardWidget(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            if (pinApplyButtonToBottom)
              Expanded(child: _buildLoadingBody())
            else
              _buildLoadingBody(),
          ],
        ),
      ),
      error: (err, _) => ProMaxGlassCardWidget(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            if (pinApplyButtonToBottom)
              Expanded(
                child: AppErrorView(
                  message: context.l10n.productLoadFailed('$err'),
                  onRetry: onCategoryTreeRetry,
                ),
              )
            else
              AppErrorView(
                message: context.l10n.productLoadFailed('$err'),
                onRetry: onCategoryTreeRetry,
              ),
          ],
        ),
      ),
      data: (categories) {
        final treeContent = _buildCategoryList(categories);
        return ProMaxGlassCardWidget(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              if (pinApplyButtonToBottom)
                Expanded(
                  child: SingleChildScrollView(
                    child: treeContent,
                  ),
                )
              else
                treeContent,
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTreeNode extends StatefulWidget {
  const _CategoryTreeNode({
    required this.category,
    required this.selectedCategoryId,
    required this.onCategoryTap,
    required this.depth,
  });

  final ProductCategoryTreeDto category;
  final int? selectedCategoryId;
  final ValueChanged<ProductCategoryTreeDto> onCategoryTap;
  final int depth;

  @override
  State<_CategoryTreeNode> createState() => _CategoryTreeNodeState();
}

class _CategoryTreeNodeState extends State<_CategoryTreeNode> {
  bool _expanded = false;

  bool _containsSelected(ProductCategoryTreeDto node, int? selectedId) {
    if (selectedId == null) return false;
    if (node.id == selectedId) return true;
    for (final child in node.children) {
      if (_containsSelected(child, selectedId)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final categoryId = widget.category.id;
    final categoryName = widget.category.name ?? '';
    final children = widget.category.children;
    final childDepth = widget.depth + 1;
    final hasChildren = children.isNotEmpty;
    final isCompactNode = widget.depth >= 2;
    final tileHeight = switch (widget.depth) {
      0 => 40.0,
      1 => 30.0,
      _ => 26.0,
    };
    final fontSize = switch (widget.depth) {
      0 => 13.0,
      1 => 12.0,
      _ => 11.0,
    };
    final tileRadius = switch (widget.depth) {
      0 => 12.0,
      1 => 10.0,
      _ => 9.0,
    };
    final selected = _containsSelected(
      widget.category,
      widget.selectedCategoryId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: isCompactNode
              ? const BoxConstraints(minWidth: 72, maxWidth: 120)
              : const BoxConstraints(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            width: isCompactNode ? null : double.infinity,
            height: tileHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tileRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? const [Color(0x4A2C3F58), Color(0x36131D2F)]
                    : const [Color(0x1AFFFFFF), Color(0x120F1727)],
              ),
              border: Border.all(
                color: selected
                    ? ProMaxTokens.inputBorderFocused.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: _CategoryNameButton(
                    onTap: categoryId == null
                        ? null
                        : () => widget.onCategoryTap(widget.category),
                    categoryName: categoryName,
                    selected: selected,
                    fontSize: fontSize,
                  ),
                ),
                if (hasChildren) ...[
                  if (selected && !isCompactNode)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ProMaxTokens.iconPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${children.length}',
                        style: const TextStyle(
                          color: ProMaxTokens.iconPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkResponse(
                      onTap: () => setState(() => _expanded = !_expanded),
                      customBorder: const CircleBorder(),
                      containedInkWell: true,
                      highlightShape: BoxShape.circle,
                      radius: 12,
                      splashColor: Colors.white.withValues(alpha: 0.16),
                      highlightColor: Colors.white.withValues(alpha: 0.12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(
                          child: AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            turns: _expanded ? 0.5 : 0,
                            child: Icon(
                              Icons.expand_more_rounded,
                              size: 19,
                              color: ProMaxTokens.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasChildren) ...[
          _AnimatedExpand(
            expanded: _expanded,
            child: Padding(
              padding: EdgeInsets.only(
                left: childDepth >= 2 ? 0 : 10,
                top: 6,
              ),
              child: childDepth >= 2
                  ? Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: children
                          .map(
                            (child) => _CategoryTreeNode(
                              category: child,
                              selectedCategoryId: widget.selectedCategoryId,
                              onCategoryTap: widget.onCategoryTap,
                              depth: childDepth,
                            ),
                          )
                          .toList(growable: false),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children
                          .map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _CategoryTreeNode(
                                category: child,
                                selectedCategoryId:
                                    widget.selectedCategoryId,
                                onCategoryTap: widget.onCategoryTap,
                                depth: childDepth,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryNameButton extends StatelessWidget {
  const _CategoryNameButton({
    required this.onTap,
    required this.categoryName,
    required this.selected,
    required this.fontSize,
  });

  final VoidCallback? onTap;
  final String categoryName;
  final bool selected;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ProMaxTokens.textPrimary,
              fontSize: fontSize,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedExpand extends StatelessWidget {
  const _AnimatedExpand({required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        heightFactor: expanded ? 1 : 0,
        child: child,
      ),
    );
  }
}
