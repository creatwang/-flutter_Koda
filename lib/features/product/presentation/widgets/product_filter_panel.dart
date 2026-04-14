import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/product/models/product_category_tree_dto.dart';

class ProductFilterPanel extends StatelessWidget {
  const ProductFilterPanel({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
    required this.onApplyTap,
    required this.onCollapseTap,
    required this.pinApplyButtonToBottom,
    super.key,
  });

  final List<ProductCategoryTreeDto> categories;
  final int? selectedCategoryId;
  final ValueChanged<ProductCategoryTreeDto> onCategoryTap;
  final VoidCallback onApplyTap;
  final VoidCallback? onCollapseTap;
  final bool pinApplyButtonToBottom;

  @override
  Widget build(BuildContext context) {
    final treeContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.isEmpty
          ? [
              Text(
                'No categories',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
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
                  ),
                ),
              )
              .toList(growable: false),
    );

    final filterBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Product Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 16,
                    ),
              ),
            ),
            if (onCollapseTap != null)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onCollapseTap,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.keyboard_double_arrow_left,
                    size: 13,
                    color: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        treeContent,
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF22262B).withValues(alpha: 0.70),
                const Color(0xFF2B2F34).withValues(alpha: 0.54),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pinApplyButtonToBottom)
                  Expanded(
                    child: SingleChildScrollView(
                      child: filterBody,
                    ),
                  )
                else
                  filterBody,
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onApplyTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA19E9A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTreeNode extends StatefulWidget {
  const _CategoryTreeNode({
    required this.category,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  final ProductCategoryTreeDto category;
  final int? selectedCategoryId;
  final ValueChanged<ProductCategoryTreeDto> onCategoryTap;

  @override
  State<_CategoryTreeNode> createState() => _CategoryTreeNodeState();
}

class _CategoryTreeNodeState extends State<_CategoryTreeNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final categoryId = widget.category.id;
    final categoryName = widget.category.name ?? '';
    final children = widget.category.children;
    final hasChildren = children.isNotEmpty;
    final selected = categoryId != null && widget.selectedCategoryId == categoryId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? Colors.white.withValues(alpha: 0.26)
                : Colors.white.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: categoryId == null ? null : () => widget.onCategoryTap(widget.category),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (hasChildren)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasChildren) ...[
          _AnimatedExpand(
            expanded: _expanded,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _CategoryTreeNode(
                          category: child,
                          selectedCategoryId: widget.selectedCategoryId,
                          onCategoryTap: widget.onCategoryTap,
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

class _AnimatedExpand extends StatelessWidget {
  const _AnimatedExpand({
    required this.expanded,
    required this.child,
  });

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
