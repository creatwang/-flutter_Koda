import 'package:flutter/material.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// Profile 右侧 Settings / My Customers / Order Center / Favorites
/// 共用的顶栏：左侧大标题 + 右侧可选 [trailing]。
class ProfileSectionHeaderWidget extends StatelessWidget {
  const ProfileSectionHeaderWidget({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  static const TextStyle _titleStyle = TextStyle(
    color: ProMaxTokens.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    shadows: [
      Shadow(
        color: Color(0x55000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(title, style: _titleStyle),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// My Customers：顶栏右侧「Add Customer」「Set Command Password」。
class ProfileMyCustomersHeaderActionsWidget extends StatelessWidget {
  const ProfileMyCustomersHeaderActionsWidget({
    super.key,
    required this.onAddCustomer,
    required this.onSetCommandPassword,
  });

  final VoidCallback onAddCustomer;
  final VoidCallback onSetCommandPassword;

  static const double _buttonHeight = 34;

  static ButtonStyle _pillButtonStyle() => TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(0, _buttonHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _buttonHeight,
          child: TextButton.icon(
            onPressed: onAddCustomer,
            icon: const Icon(Icons.add, size: 14),
            label: const Text(
              'Add Customer',
              style: TextStyle(fontSize: 14),
            ),
            style: _pillButtonStyle(),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: _buttonHeight,
          child: TextButton(
            onPressed: onSetCommandPassword,
            style: _pillButtonStyle(),
            child: const Text(
              'Set Command Password',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// Settings：顶栏右侧刷新（与订单 Tab、客户按钮同一行占位逻辑）。
class ProfileSectionHeaderRefreshButton extends StatelessWidget {
  const ProfileSectionHeaderRefreshButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProMaxTokens.cardBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isEnabled ? onPressed : null,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.refresh,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}
