import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/profile/models/profile_content_section.dart';

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
  required bool isSalesRep,
}) {
  return <ProfileSectionMeta>[
    const ProfileSectionMeta(
      section: ProfileContentSection.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
    if (isSalesRep)
      const ProfileSectionMeta(
        section: ProfileContentSection.myCustomers,
        label: 'My Customers',
        icon: Icons.groups_outlined,
      ),
    const ProfileSectionMeta(
      section: ProfileContentSection.orderCenter,
      label: 'Order Center',
      icon: Icons.notifications_none_outlined,
    ),
    const ProfileSectionMeta(
      section: ProfileContentSection.favorites,
      label: 'Favorites',
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
