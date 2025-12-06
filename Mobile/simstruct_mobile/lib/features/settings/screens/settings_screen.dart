import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _hapticFeedback = true;
  bool _autoSync = true;
  String _language = 'English';
  String _units = 'Metric';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _SettingsSection(
              title: 'Appearance',
              icon: Iconsax.brush_1,
              children: [
                _SettingsSwitch(
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme',
                  icon: Iconsax.moon,
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                _SettingsTile(
                  title: 'Language',
                  subtitle: _language,
                  icon: Iconsax.global,
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 20),

            // General Section
            _SettingsSection(
              title: 'General',
              icon: Iconsax.setting_2,
              children: [
                _SettingsTile(
                  title: 'Units',
                  subtitle: _units,
                  icon: Iconsax.ruler,
                  onTap: () => _showUnitsDialog(),
                ),
                _SettingsSwitch(
                  title: 'Haptic Feedback',
                  subtitle: 'Vibration on actions',
                  icon: Iconsax.mobile,
                  value: _hapticFeedback,
                  onChanged: (v) => setState(() => _hapticFeedback = v),
                ),
                _SettingsSwitch(
                  title: 'Auto Sync',
                  subtitle: 'Sync data automatically',
                  icon: Iconsax.refresh_circle,
                  value: _autoSync,
                  onChanged: (v) => setState(() => _autoSync = v),
                ),
              ],
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Data Section
            _SettingsSection(
              title: 'Data & Storage',
              icon: Iconsax.folder,
              children: [
                _SettingsTile(
                  title: 'Clear Cache',
                  subtitle: '125 MB used',
                  icon: Iconsax.trash,
                  onTap: () => _clearCache(),
                ),
                _SettingsTile(
                  title: 'Export Data',
                  subtitle: 'Download your simulations',
                  icon: Iconsax.export_1,
                  onTap: () {},
                ),
              ],
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Support Section
            _SettingsSection(
              title: 'Support',
              icon: Iconsax.support,
              children: [
                _SettingsTile(
                  title: 'Help Center',
                  subtitle: 'FAQs and guides',
                  icon: Iconsax.book,
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Contact Support',
                  subtitle: 'Get help from our team',
                  icon: Iconsax.message_question,
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Report a Bug',
                  subtitle: 'Help us improve',
                  icon: Iconsax.danger,
                  onTap: () {},
                ),
              ],
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 20),

            // About Section
            _SettingsSection(
              title: 'About',
              icon: Iconsax.info_circle,
              children: [
                _SettingsTile(
                  title: 'Version',
                  subtitle: '1.0.0 (Build 1)',
                  icon: Iconsax.code,
                  onTap: null,
                ),
                _SettingsTile(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  icon: Iconsax.document_text,
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  icon: Iconsax.shield_tick,
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Licenses',
                  subtitle: 'Open source licenses',
                  icon: Iconsax.document,
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Logout Button
            CustomButton(
              text: 'Sign Out',
              onPressed: () => _handleLogout(),
              type: ButtonType.outline,
              icon: Iconsax.logout,
              isFullWidth: true,
            ).animate(delay: 500.ms).fadeIn(),

            const SizedBox(height: 16),

            // Delete Account
            Center(
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(),
                child: Text(
                  'Delete Account',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ).animate(delay: 550.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'French', 'Arabic', 'Spanish'].map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Metric', 'Imperial'].map((unit) {
            return RadioListTile<String>(
              title: Text(unit),
              value: unit,
              groupValue: _units,
              onChanged: (value) {
                setState(() => _units = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _clearCache() {
    SnackbarHelper.showSuccess(context, 'Cache cleared successfully');
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthService>().logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showInfo(context, 'Feature coming soon');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.labelSmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            )
          : null,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.labelSmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
