import 'package:flutter/material.dart';

class HeaderMenuButton extends StatelessWidget {
  const HeaderMenuButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  static const double _radius = 10;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : Colors.black87;
    final selectedForeground = isDark ? Colors.white : const Color(0xFF1E3B73);
    final selectedBackground = isDark
        ? const Color.fromRGBO(0, 0, 0, 0.16)
        : const Color.fromRGBO(255, 255, 255, 0.62);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
            foregroundColor: selected ? selectedForeground : foreground,
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        ),
      ),
    );
  }
}
