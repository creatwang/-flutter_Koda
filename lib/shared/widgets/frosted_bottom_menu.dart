import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedBottomMenuItem {
  const FrostedBottomMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class FrostedBottomMenu extends StatelessWidget {
  const FrostedBottomMenu({
    required this.items,
    super.key,
  });

  final List<FrostedBottomMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.36),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items
                    .map(
                      (item) => _BottomMenuTile(
                        icon: item.icon,
                        label: item.label,
                        selected: item.selected,
                        onTap: item.onTap,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomMenuTile extends StatelessWidget {
  const _BottomMenuTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBackground = isDark
        ? const Color.fromRGBO(0, 0, 0, 0.16)
        : const Color.fromRGBO(255, 255, 255, 0.62);
    final selectedColor = isDark ? Colors.white : const Color(0xFF1E3B73);
    final normalColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : Colors.black.withValues(alpha: 0.72);

    return SizedBox(
      width: 84,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? selectedBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: selected ? selectedColor : normalColor,
                ),
                const SizedBox(height: 3),
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 7,
                    letterSpacing: 0.6,
                    color: selected ? selectedColor : normalColor,
                    fontWeight: FontWeight.w500,
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
