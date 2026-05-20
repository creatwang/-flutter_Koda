import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/profile/models/profile_content_section.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';

/// 个人中心侧栏一项：分区、展示文案与图标。
final class ProfileSectionMeta {
  const ProfileSectionMeta({
    required this.section,
    required this.label,
    required this.icon,
  });

  final ProfileContentSection section;
  final String label;
  final IconData icon;
}

List<ProfileSectionMeta> buildProfileSidebarMenus({
  required AppLocalizations l10n,
  required bool isSalesRep,
}) {
  return <ProfileSectionMeta>[
    ProfileSectionMeta(
      section: ProfileContentSection.settings,
      label: l10n.profileMenuSettings,
      icon: Icons.settings_outlined,
    ),
    if (isSalesRep)
      ProfileSectionMeta(
        section: ProfileContentSection.myCustomers,
        label: l10n.profileMenuMyCustomers,
        icon: Icons.groups_outlined,
      ),
    ProfileSectionMeta(
      section: ProfileContentSection.orderCenter,
      label: l10n.profileMenuOrderCenter,
      icon: Icons.notifications_none_outlined,
    ),
    ProfileSectionMeta(
      section: ProfileContentSection.favorites,
      label: l10n.profileMenuFavorites,
      icon: Icons.favorite_border,
    ),
  ];
}

ProfileContentSection resolveProfileVisibleSection(
  List<ProfileSectionMeta> menus,
  ProfileContentSection current,
) {
  if (menus.any((m) => m.section == current)) return current;
  return ProfileContentSection.settings;
}
