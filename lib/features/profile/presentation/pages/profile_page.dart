import 'package:flutter/material.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';

enum ProfileContentSection {
  settings,
  myCustomers,
  orderCenter,
  favorites,
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileContentSection _currentSection = ProfileContentSection.settings;
  final TextEditingController _fullNameController =
      TextEditingController(text: 'Molin Chen');
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showSettingsValidation = false;
  String? _settingsErrorMessage;

  static const List<_ProfileSectionMeta> _menus = <_ProfileSectionMeta>[
    _ProfileSectionMeta(
      section: ProfileContentSection.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
    _ProfileSectionMeta(
      section: ProfileContentSection.myCustomers,
      label: 'My Customers',
      icon: Icons.groups_outlined,
    ),
    _ProfileSectionMeta(
      section: ProfileContentSection.orderCenter,
      label: 'Order Center',
      icon: Icons.notifications_none_outlined,
    ),
    _ProfileSectionMeta(
      section: ProfileContentSection.favorites,
      label: 'Favorites',
      icon: Icons.favorite_border,
    ),
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isFieldEmpty(TextEditingController controller) =>
      controller.text.trim().isEmpty;

  bool _validateSettingsForm() {
    final hasEmpty = _isFieldEmpty(_fullNameController) ||
        _isFieldEmpty(_oldPasswordController) ||
        _isFieldEmpty(_newPasswordController) ||
        _isFieldEmpty(_confirmPasswordController);
    if (hasEmpty) {
      _settingsErrorMessage = 'All fields are required.';
      return false;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _settingsErrorMessage =
          'New Password and Confirm Password must match.';
      return false;
    }
    _settingsErrorMessage = null;
    return true;
  }

  void _onSaveSettings() {
    setState(() => _showSettingsValidation = true);
    _validateSettingsForm();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeta = _menus.firstWhere(
      (item) => item.section == _currentSection,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
          _ProfileSidebar(
            currentSection: _currentSection,
            menus: _menus,
            onSectionChanged: (next) => setState(() => _currentSection = next),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _ProfileContentArea(
              currentSection: _currentSection,
              title: selectedMeta.label,
              fullNameController: _fullNameController,
              oldPasswordController: _oldPasswordController,
              newPasswordController: _newPasswordController,
              confirmPasswordController: _confirmPasswordController,
              showValidation: _showSettingsValidation,
              validationMessage: _settingsErrorMessage,
              onSaveSettings: _onSaveSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSidebar extends StatelessWidget {
  const _ProfileSidebar({
    required this.currentSection,
    required this.menus,
    required this.onSectionChanged,
  });

  final ProfileContentSection currentSection;
  final List<_ProfileSectionMeta> menus;
  final ValueChanged<ProfileContentSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black26,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Julian Vance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'SENIOR CURATOR',
                    style: TextStyle(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    value: '128',
                    label: 'SAVED ITEMS',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatTile(
                    value: '24',
                    label: 'CONCEPTS',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'ACCOUNT & PREFERENCES',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                letterSpacing: 1.5,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...menus.map((menu) {
              final isSelected = menu.section == currentSection;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ProfileMenuTile(
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
  }
}

class _ProfileContentArea extends StatelessWidget {
  const _ProfileContentArea({
    required this.currentSection,
    required this.title,
    required this.fullNameController,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.showValidation,
    required this.validationMessage,
    required this.onSaveSettings,
  });

  final ProfileContentSection currentSection;
  final String title;
  final TextEditingController fullNameController;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool showValidation;
  final String? validationMessage;
  final VoidCallback onSaveSettings;

  @override
  Widget build(BuildContext context) {
    final isSettings = currentSection == ProfileContentSection.settings;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            if (isSettings) ...[
              const Text(
                'Account Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SettingsInputField(
                            label: 'FULL NAME',
                            controller: fullNameController,
                            obscureText: false,
                            showError: showValidation &&
                                fullNameController.text.trim().isEmpty,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SettingsInputField(
                            label: 'OLD PASSWORD',
                            controller: oldPasswordController,
                            obscureText: true,
                            showError: showValidation &&
                                oldPasswordController.text.trim().isEmpty,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SettingsInputField(
                            label: 'NEW PASSWORD',
                            controller: newPasswordController,
                            obscureText: true,
                            showError: showValidation &&
                                newPasswordController.text.trim().isEmpty,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SettingsInputField(
                            label: 'CONFIRM PASSWORD',
                            controller: confirmPasswordController,
                            obscureText: true,
                            showError: showValidation &&
                                confirmPasswordController.text.trim().isEmpty,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (validationMessage != null)
                      SelectableText.rich(
                        TextSpan(
                          text: validationMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (validationMessage != null) const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: onSaveSettings,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Another Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(
                    child: _SettingsActionTile(
                      icon: Icons.compare_arrows_rounded,
                      text: 'switch  Account',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _SettingsActionTile(
                      icon: Icons.power_settings_new,
                      text: 'logout',
                    ),
                  ),
                ],
              ),
            ] else
              Expanded(
                child: AppEmptyView(
                  message: '$title is empty',
                  width: 130,
                  height: 130,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Colors.black.withValues(alpha: 0.32)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.24)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsInputField extends StatelessWidget {
  const _SettingsInputField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.showError,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.86),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            hintText: obscureText ? '********' : 'Molin Chen',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            errorText: showError ? 'Required' : null,
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 8,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionMeta {
  const _ProfileSectionMeta({
    required this.section,
    required this.label,
    required this.icon,
  });

  final ProfileContentSection section;
  final String label;
  final IconData icon;
}
