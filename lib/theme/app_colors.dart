import 'package:flutter/material.dart';

/// 全局颜色令牌（Design Tokens）
/// 约定：业务代码尽量引用这里，避免页面里散落十六进制颜色值。
class AppColors {
  const AppColors._();

  // Brand
  static const brandPrimary = Color(0xFF4F6DDB);
  static const brandOnPrimary = Colors.white;

  // Text
  static const textPrimary = Color(0xFF121826);
  static const textSecondary = Color(0xFF5F6673);
  static const textOnDark = Colors.white;

  // Surface / Background
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF4F6F8);
  static const appBarBackground = Color(0x24000000); // 黑色 14%

  // Button
  static const buttonPrimary = brandPrimary;
  static const buttonPrimaryText = brandOnPrimary;
  static const buttonSecondary = Color.fromRGBO(0, 0, 0, 0.1); // 黑色半透明
  static const buttonSecondaryText = Color(0xE6FFFFFF); // 白色半透明

  // State
  static const success = Color(0xFF2E9B53);
  static const warning = Color(0xFFE6A500);
  static const error = Color(0xFFCD3B3B);
}
