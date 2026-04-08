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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            foregroundColor:
                selected ? colorScheme.primary : colorScheme.onSurface,
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        ),
      ),
    );
  }
}
