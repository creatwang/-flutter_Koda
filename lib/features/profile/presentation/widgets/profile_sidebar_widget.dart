import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/profile/models/profile_content_section.dart';
import 'package:groe_app_pad/features/profile/models/profile_section_meta.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_glass_card_widget.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

import '../../../../gen/assets.gen.dart' show Assets;

class ProfileSidebarWidget extends StatelessWidget {
  const ProfileSidebarWidget({
    super.key,
    required this.avatarUrl,
    required this.profileName,
    required this.profileId,
    required this.favoriteCount,
    required this.cartBadgeCount,
    required this.currentSection,
    required this.menus,
    required this.onSectionChanged,
  });

  final String avatarUrl;
  final String profileName;
  final int? profileId;
  final int favoriteCount;
  final int cartBadgeCount;
  final ProfileContentSection currentSection;
  final List<ProfileSectionMeta> menus;
  final ValueChanged<ProfileContentSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return ProMaxGlassCardWidget(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 230,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
                bottom: 18,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: -0.06,
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEFF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.92),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3D67B2,
                                  ).withValues(alpha: 0.42),
                                  blurRadius: 12,
                                  spreadRadius: 0.5,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ColoredBox(
                                color: Colors.black26,
                                child: avatarUrl.trim().isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                    : Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Assets.svg.profileSetting.svg(width: 24, height: 24),
                        const SizedBox(height: 36),
                        Text(
                          profileName.trim().isEmpty ? '--' : profileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'UID: ${profileId ?? '--'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            letterSpacing: 1.4,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ProfileStatTileWidget(
                              value: '$favoriteCount',
                              label: 'FAV NUM',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProfileStatTileWidget(
                              value: '$cartBadgeCount',
                              label: 'CART NUM',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'ACCOUNT & PREFERENCES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: 1.6,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...menus.map((menu) {
                      final isSelected = menu.section == currentSection;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProfileMenuTileWidget(
                          label: menu.label,
                          icon: menu.icon,
                          selected: isSelected,
                          onTap: () => onSectionChanged(menu.section),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileMenuTileWidget extends StatelessWidget {
  const ProfileMenuTileWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedTextColor = Color(0xFFD5DAE2);
    const selectedIconColor = Color(0xFFB8C0CC);
    const selectedBorderColor = Color(0x66737E8D);
    const unselectedBorderColor = Color(0x33FFFFFF);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? const [Color(0x5639404A), Color(0x3A1E232B)]
                  : const [Color(0x14FFFFFF), Color(0x120E1626)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? selectedBorderColor : unselectedBorderColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? selectedIconColor : Colors.white70,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? selectedTextColor
                        : ProMaxTokens.textPrimary,
                    fontSize: 12,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: selected
                    ? selectedIconColor
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileStatTileWidget extends StatelessWidget {
  const ProfileStatTileWidget({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ProMaxGlassCardWidget(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: ProMaxTokens.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 8,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
