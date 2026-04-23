import 'package:flutter/material.dart';
import 'package:george_pick_mate/app/providers/theme_provider.dart';
import 'package:george_pick_mate/theme/app_colors.dart';

ThemeData buildAppTheme(AppThemeMode mode) {
  final isDark = mode == AppThemeMode.dark;
  const radius = 10.0;
  final base = ThemeData(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brandPrimary,
    brightness: isDark ? Brightness.dark : Brightness.light,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ).copyWith(
      backgroundColor: isDark
          ? AppColors.appBarBackground
          : Colors.white.withValues(alpha: 0.45),
      foregroundColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      actionsIconTheme: IconThemeData(
        color: isDark ? AppColors.brandOnPrimary : AppColors.textPrimary,
      ),
      titleTextStyle: TextStyle(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonPrimaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
  );
}
