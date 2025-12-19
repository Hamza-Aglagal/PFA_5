import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/simulation_params.dart';

class StructureStep extends StatelessWidget {
  final SimulationParams params;
  final Function(SimulationParams) onChanged;

  const StructureStep({
    super.key,
    required this.params,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Select Structure Type',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Choose the type of structure you want to analyze',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ).animate(delay: 50.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 24),

          // Structure Type Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: StructureType.values.map((type) {
              final isSelected = params.structureType == type;
              return _StructureCard(
                type: type,
                isSelected: isSelected,
                onTap: () => onChanged(params.copyWith(structureType: type)),
              );
            }).toList(),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 32),

          // Support Type Section
          Text(
            'Support Conditions',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: SupportType.values.map((type) {
              final isSelected = params.supportType == type;
              return _SupportChip(
                type: type,
                isSelected: isSelected,
                onTap: () => onChanged(params.copyWith(supportType: type)),
              );
            }).toList(),
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 32),

          // Building Configuration for AI
          Text(
            'Building Configuration',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 16),

          // Number of Floors & Floor Height
          Row(
            children: [
              Expanded(
                child: _NumberInput(
                  label: 'Floors',
                  value: params.numFloors,
                  min: 1, max: 50,
                  onChanged: (v) => onChanged(params.copyWith(numFloors: v)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _NumberInput(
                  label: 'Floor Height (m)',
                  value: params.floorHeight,
                  min: 2.5, max: 6.0, step: 0.1,
                  onChanged: (v) => onChanged(params.copyWith(floorHeight: v)),
                ),
              ),
            ],
          ).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 16),

          // Beams & Columns
          Row(
            children: [
              Expanded(
                child: _NumberInput(
                  label: 'Beams',
                  value: params.numBeams.toDouble(),
                  min: 10, max: 500,
                  onChanged: (v) => onChanged(params.copyWith(numBeams: v.toInt())),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _NumberInput(
                  label: 'Columns',
                  value: params.numColumns.toDouble(),
                  min: 4, max: 200,
                  onChanged: (v) => onChanged(params.copyWith(numColumns: v.toInt())),
                ),
              ),
            ],
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: 16),

          // Section Dimensions
          Row(
            children: [
              Expanded(
                child: _NumberInput(
                  label: 'Beam Section (cm)',
                  value: params.beamSection,
                  min: 20, max: 100,
                  onChanged: (v) => onChanged(params.copyWith(beamSection: v)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _NumberInput(
                  label: 'Column Section (cm)',
                  value: params.columnSection,
                  min: 30, max: 150,
                  onChanged: (v) => onChanged(params.copyWith(columnSection: v)),
                ),
              ),
            ],
          ).animate(delay: 400.ms).fadeIn(),
        ],
      ),
    );
  }
}

// Simple number input widget
class _NumberInput extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final Function(double) onChanged;

  const _NumberInput({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1.0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        )),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged((value - step).clamp(min, max)) : null,
                child: Icon(Icons.remove, size: 18, color: AppColors.primary),
              ),
              Expanded(
                child: Text(
                  step < 1 ? value.toStringAsFixed(1) : value.toInt().toString(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              GestureDetector(
                onTap: value < max ? () => onChanged((value + step).clamp(min, max)) : null,
                child: Icon(Icons.add, size: 18, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StructureCard extends StatelessWidget {
  final StructureType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _StructureCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case StructureType.beam:
        return Iconsax.minus;
      case StructureType.frame:
        return Iconsax.grid_3;
      case StructureType.truss:
        return Iconsax.shapes;
      case StructureType.column:
        return Iconsax.ruler;
    }
  }

  String get _label {
    switch (type) {
      case StructureType.beam:
        return 'Beam';
      case StructureType.frame:
        return 'Frame';
      case StructureType.truss:
        return 'Truss';
      case StructureType.column:
        return 'Column';
    }
  }

  String get _description {
    switch (type) {
      case StructureType.beam:
        return 'Horizontal load-bearing element';
      case StructureType.frame:
        return 'Multi-member rigid structure';
      case StructureType.truss:
        return 'Triangular member system';
      case StructureType.column:
        return 'Vertical compression element';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 28,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.02, 1.02),
            duration: 200.ms,
          ),
    );
  }
}

class _SupportChip extends StatelessWidget {
  final SupportType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _SupportChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (type) {
      case SupportType.simplySupported:
        return 'Simply Supported';
      case SupportType.cantilever:
        return 'Cantilever';
      case SupportType.fixedFixed:
        return 'Fixed-Fixed';
      case SupportType.pinned:
        return 'Pinned';
      case SupportType.fixed:
        return 'Fixed';
      case SupportType.roller:
        return 'Roller';
    }
  }

  IconData get _icon {
    switch (type) {
      case SupportType.simplySupported:
        return Iconsax.maximize_3;
      case SupportType.cantilever:
        return Iconsax.arrow_left_2;
      case SupportType.fixedFixed:
        return Iconsax.box_2;
      case SupportType.pinned:
        return Iconsax.triangle;
      case SupportType.fixed:
        return Iconsax.box_1;
      case SupportType.roller:
        return Iconsax.bubble;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 20,
              color: isSelected
                  ? AppColors.secondary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 8),
            Text(
              _label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected
                    ? AppColors.secondary
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
