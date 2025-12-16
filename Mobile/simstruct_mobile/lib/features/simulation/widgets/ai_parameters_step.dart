import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';

class AIParametersStep extends StatelessWidget {
  final TextEditingController numFloorsController;
  final TextEditingController floorHeightController;
  final TextEditingController numBeamsController;
  final TextEditingController numColumnsController;
  final TextEditingController beamSectionController;
  final TextEditingController columnSectionController;
  final TextEditingController concreteStrengthController;
  final TextEditingController steelGradeController;
  final TextEditingController windLoadController;
  final TextEditingController liveLoadController;
  final TextEditingController deadLoadController;

  const AIParametersStep({
    super.key,
    required this.numFloorsController,
    required this.floorHeightController,
    required this.numBeamsController,
    required this.numColumnsController,
    required this.beamSectionController,
    required this.columnSectionController,
    required this.concreteStrengthController,
    required this.steelGradeController,
    required this.windLoadController,
    required this.liveLoadController,
    required this.deadLoadController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'AI Analysis Parameters',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Optional: Provide building details for AI-powered stability analysis',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ).animate(delay: 50.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 24),

          // Building Structure Section
          _SectionHeader(
            icon: Iconsax.building,
            title: 'Building Structure',
            isDark: isDark,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'Number of Floors',
                  controller: numFloorsController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Iconsax.layer,
                ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  hint: 'Floor Height (m)',
                  controller: floorHeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Iconsax.arrow_up_2,
                ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'Number of Beams',
                  controller: numBeamsController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Iconsax.component,
                ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  hint: 'Number of Columns',
                  controller: numColumnsController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Iconsax.align_vertically,
                ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cross Sections Section
          _SectionHeader(
            icon: Iconsax.status_up,
            title: 'Cross Sections (mm²)',
            isDark: isDark,
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'Beam Section',
                  controller: beamSectionController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Iconsax.maximize_3,
                ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  hint: 'Column Section',
                  controller: columnSectionController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Iconsax.maximize_4,
                ).animate(delay: 450.ms).fadeIn().slideX(begin: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Material Properties Section
          _SectionHeader(
            icon: Iconsax.colorfilter,
            title: 'Material Properties',
            isDark: isDark,
          ).animate(delay: 500.ms).fadeIn(),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'Concrete Strength (MPa)',
                  controller: concreteStrengthController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Iconsax.shield_tick,
                ).animate(delay: 550.ms).fadeIn().slideX(begin: -0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  hint: 'Steel Grade (MPa)',
                  controller: steelGradeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Iconsax.cpu,
                ).animate(delay: 600.ms).fadeIn().slideX(begin: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Loading Conditions Section
          _SectionHeader(
            icon: Iconsax.weight,
            title: 'Loading Conditions (kN/m²)',
            isDark: isDark,
          ).animate(delay: 650.ms).fadeIn(),
          const SizedBox(height: 16),
          
          CustomTextField(
            hint: 'Wind Load',
            controller: windLoadController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Iconsax.wind_2,
          ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 12),
          
          CustomTextField(
            hint: 'Live Load',
            controller: liveLoadController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Iconsax.people,
          ).animate(delay: 750.ms).fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 12),
          
          CustomTextField(
            hint: 'Dead Load',
            controller: deadLoadController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Iconsax.weight_1,
          ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.1),
          
          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These parameters enable AI-powered structural analysis. Leave empty to skip AI analysis.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 850.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
