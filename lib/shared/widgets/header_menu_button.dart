import 'package:flutter/material.dart';
import 'package:groe_app_pad/theme/app_colors.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.buttonSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
            foregroundColor: AppColors.textOnDark,
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        ),
      ),
    );
  }
}
