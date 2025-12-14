import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/notification_service.dart';

/// Edit Profile Bottom Sheet - Professional Design
class EditProfileSheet extends StatefulWidget {
  final User user;
  
  const EditProfileSheet({super.key, required this.user});
  
  /// Show the edit profile sheet
  static Future<bool?> show(BuildContext context, User user) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(user: user),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late TextEditingController _bioController;
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.profile.phone ?? '');
    _companyController = TextEditingController(text: widget.user.profile.company ?? '');
    _jobTitleController = TextEditingController(text: widget.user.profile.jobTitle ?? '');
    _bioController = TextEditingController(text: widget.user.profile.bio ?? '');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  /// Save profile changes
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final userService = context.read<UserService>();
    final notificationService = context.read<NotificationService>();
    final authService = context.read<AuthService>();
    
    final updatedUser = await userService.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
      jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
    );
    
    setState(() => _isLoading = false);
    
    if (updatedUser != null) {
      // Update auth service with new user data
      await authService.updateProfile(
        name: updatedUser.name,
        phone: updatedUser.profile.phone,
        company: updatedUser.profile.company,
        bio: updatedUser.profile.bio,
      );
      
      notificationService.showSuccess('Profile updated successfully! ✨');
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      notificationService.showError(userService.error ?? 'Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.user_edit,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profile',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Update your personal information',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Field
                    _ProfileTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Iconsax.user,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ).animate(delay: 50.ms).fadeIn().slideX(begin: 0.05),
                    
                    const SizedBox(height: 16),
                    
                    // Phone Field
                    _ProfileTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+1 234 567 8900',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                    ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.05),
                    
                    const SizedBox(height: 16),
                    
                    // Company Field
                    _ProfileTextField(
                      controller: _companyController,
                      label: 'Company',
                      hint: 'Where do you work?',
                      icon: Iconsax.building,
                    ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.05),
                    
                    const SizedBox(height: 16),
                    
                    // Job Title Field
                    _ProfileTextField(
                      controller: _jobTitleController,
                      label: 'Job Title',
                      hint: 'e.g. Civil Engineer',
                      icon: Iconsax.briefcase,
                    ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.05),
                    
                    const SizedBox(height: 16),
                    
                    // Bio Field
                    _ProfileTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell us about yourself...',
                      icon: Iconsax.document_text,
                      maxLines: 3,
                    ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.05),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          
          // Save Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.tick_circle, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
        ],
      ),
    );
  }
}

/// Custom text field for profile editing
class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            filled: true,
            fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
