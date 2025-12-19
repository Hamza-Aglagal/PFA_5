import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/simulation_params.dart';

class DimensionsStep extends StatefulWidget {
  final SimulationParams params;
  final Function(SimulationParams) onChanged;

  const DimensionsStep({
    super.key,
    required this.params,
    required this.onChanged,
  });

  @override
  State<DimensionsStep> createState() => _DimensionsStepState();
}

class _DimensionsStepState extends State<DimensionsStep> {
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _lengthController = TextEditingController(
      text: widget.params.length.toString(),
    );
    _widthController = TextEditingController(
      text: widget.params.width.toString(),
    );
    _heightController = TextEditingController(
      text: widget.params.height.toString(),
    );
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _updateDimensions() {
    widget.onChanged(widget.params.copyWith(
      length: double.tryParse(_lengthController.text),
      width: double.tryParse(_widthController.text),
      height: double.tryParse(_heightController.text),
    ));
  }

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
            'Define Dimensions',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Enter the dimensions of your ${widget.params.structureType.name}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ).animate(delay: 50.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 24),

          // Unit Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.ruler,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Unit:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: DimensionUnits.values.map((unit) {
                      final isSelected = widget.params.dimensionUnits == unit;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            widget.onChanged(widget.params.copyWith(dimensionUnits: unit));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              unit.name,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 24),

          // Dimension Inputs
          _DimensionInput(
            label: 'Length',
            hint: 'Enter length',
            controller: _lengthController,
            unit: widget.params.dimensionUnits.name,
            icon: Iconsax.arrow_right_3,
            onChanged: _updateDimensions,
          ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.1),

          const SizedBox(height: 16),

          _DimensionInput(
            label: 'Width',
            hint: 'Enter width',
            controller: _widthController,
            unit: widget.params.dimensionUnits.name,
            icon: Iconsax.arrow_left_3,
            onChanged: _updateDimensions,
          ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1),

          const SizedBox(height: 16),

          _DimensionInput(
            label: 'Height',
            hint: 'Enter height',
            controller: _heightController,
            unit: widget.params.dimensionUnits.name,
            icon: Iconsax.arrow_up_2,
            onChanged: _updateDimensions,
          ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.1),

          const SizedBox(height: 32),

          // 3D Preview Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.box,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3D Preview',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coming soon',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Environmental Loads for AI
          Text(
            'Environmental Loads',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LoadNumberInput(
                  label: 'Wind (kN/m²)',
                  value: widget.params.windLoad,
                  min: 0.5, max: 3.0, step: 0.1,
                  onChanged: (v) => widget.onChanged(widget.params.copyWith(windLoad: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LoadNumberInput(
                  label: 'Live (kN/m²)',
                  value: widget.params.liveLoad,
                  min: 1.5, max: 5.0, step: 0.1,
                  onChanged: (v) => widget.onChanged(widget.params.copyWith(liveLoad: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LoadNumberInput(
                  label: 'Dead (kN/m²)',
                  value: widget.params.deadLoad,
                  min: 3.0, max: 8.0, step: 0.1,
                  onChanged: (v) => widget.onChanged(widget.params.copyWith(deadLoad: v)),
                ),
              ),
            ],
          ).animate(delay: 400.ms).fadeIn(),
        ],
      ),
    );
  }
}

// Simple number input for load params
class _LoadNumberInput extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final Function(double) onChanged;

  const _LoadNumberInput({
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
        Text(label, style: AppTextStyles.labelSmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        )),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged(double.parse(((value - step).clamp(min, max)).toStringAsFixed(1))) : null,
                child: Icon(Icons.remove, size: 16, color: AppColors.primary),
              ),
              Expanded(
                child: Text(
                  value.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              GestureDetector(
                onTap: value < max ? () => onChanged(double.parse(((value + step).clamp(min, max)).toStringAsFixed(1))) : null,
                child: Icon(Icons.add, size: 16, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DimensionInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String unit;
  final IconData icon;
  final VoidCallback onChanged;

  const _DimensionInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.unit,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: Text(
                  unit,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
