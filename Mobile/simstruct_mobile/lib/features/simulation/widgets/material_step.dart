import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/simulation_params.dart';

class MaterialStep extends StatefulWidget {
  final SimulationParams params;
  final Function(SimulationParams) onChanged;

  const MaterialStep({
    super.key,
    required this.params,
    required this.onChanged,
  });

  @override
  State<MaterialStep> createState() => _MaterialStepState();
}

class _MaterialStepState extends State<MaterialStep> {
  late TextEditingController _loadValueController;

  @override
  void initState() {
    super.initState();
    _loadValueController = TextEditingController(
      text: widget.params.loadValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _loadValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material Section
          Text(
            'Select Material',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Choose the material for your structure',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ).animate(delay: 50.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 20),

          // Material Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: StructuralMaterial.values.map((type) {
              final isSelected = widget.params.material == type;
              return _MaterialCard(
                type: type,
                isSelected: isSelected,
                onTap: () => widget.onChanged(
                  widget.params.copyWith(material: type),
                ),
              );
            }).toList(),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 32),

          // Load Type Section
          Text(
            'Load Configuration',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 16),

          // Load Type Selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: LoadType.values.map((type) {
              final isSelected = widget.params.loadType == type;
              return _LoadTypeChip(
                type: type,
                isSelected: isSelected,
                onTap: () => widget.onChanged(
                  widget.params.copyWith(loadType: type),
                ),
              );
            }).toList(),
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 24),

          // Load Value Input
          Row(
            children: [
              Expanded(
                child: _LoadValueInput(
                  controller: _loadValueController,
                  onChanged: () {
                    widget.onChanged(widget.params.copyWith(
                      loadValue: double.tryParse(_loadValueController.text),
                    ));
                  },
                ),
              ),
              const SizedBox(width: 12),
              _UnitSelector(
                selectedUnit: widget.params.loadUnits,
                onChanged: (unit) => widget.onChanged(
                  widget.params.copyWith(loadUnits: unit),
                ),
              ),
            ],
          ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 32),

          // Material Properties Preview
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Material Properties',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MaterialProperty(
                  label: 'Elastic Modulus',
                  value: _getElasticModulus(widget.params.material),
                ),
                const SizedBox(height: 8),
                _MaterialProperty(
                  label: 'Yield Strength',
                  value: _getYieldStrength(widget.params.material),
                ),
                const SizedBox(height: 8),
                _MaterialProperty(
                  label: 'Density',
                  value: _getDensity(widget.params.material),
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Additional Material Properties for AI
          Text(
            'AI Material Parameters',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AINumberInput(
                  label: 'Concrete (MPa)',
                  value: widget.params.concreteStrength,
                  min: 20, max: 90,
                  onChanged: (v) => widget.onChanged(widget.params.copyWith(concreteStrength: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AINumberInput(
                  label: 'Steel Grade (MPa)',
                  value: widget.params.steelGrade,
                  min: 235, max: 460, step: 5,
                  onChanged: (v) => widget.onChanged(widget.params.copyWith(steelGrade: v)),
                ),
              ),
            ],
          ).animate(delay: 400.ms).fadeIn(),
        ],
      ),
    );
  }

  String _getElasticModulus(StructuralMaterial type) {
    switch (type) {
      case StructuralMaterial.concrete:
        return '30 GPa';
      case StructuralMaterial.steel:
        return '200 GPa';
      case StructuralMaterial.wood:
        return '12 GPa';
      case StructuralMaterial.aluminum:
        return '70 GPa';
    }
  }

  String _getYieldStrength(StructuralMaterial type) {
    switch (type) {
      case StructuralMaterial.concrete:
        return '30 MPa';
      case StructuralMaterial.steel:
        return '250 MPa';
      case StructuralMaterial.wood:
        return '40 MPa';
      case StructuralMaterial.aluminum:
        return '280 MPa';
    }
  }

  String _getDensity(StructuralMaterial type) {
    switch (type) {
      case StructuralMaterial.concrete:
        return '2,400 kg/m³';
      case StructuralMaterial.steel:
        return '7,850 kg/m³';
      case StructuralMaterial.wood:
        return '600 kg/m³';
      case StructuralMaterial.aluminum:
        return '2,700 kg/m³';
    }
  }
}

class _MaterialCard extends StatelessWidget {
  final StructuralMaterial type;
  final bool isSelected;
  final VoidCallback onTap;

  const _MaterialCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case StructuralMaterial.concrete:
        return Iconsax.box_1;
      case StructuralMaterial.steel:
        return Iconsax.weight;
      case StructuralMaterial.wood:
        return Iconsax.tree;
      case StructuralMaterial.aluminum:
        return Iconsax.layer;
    }
  }

  String get _label {
    switch (type) {
      case StructuralMaterial.concrete:
        return 'Concrete';
      case StructuralMaterial.steel:
        return 'Steel';
      case StructuralMaterial.wood:
        return 'Wood';
      case StructuralMaterial.aluminum:
        return 'Aluminum';
    }
  }

  Color get _color {
    switch (type) {
      case StructuralMaterial.concrete:
        return Colors.grey;
      case StructuralMaterial.steel:
        return Colors.blueGrey;
      case StructuralMaterial.wood:
        return Colors.brown;
      case StructuralMaterial.aluminum:
        return Colors.purple;
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
              ? _color.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _color
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? _color : _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 24,
                color: isSelected ? Colors.white : _color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _label,
              style: AppTextStyles.titleSmall.copyWith(
                color: isSelected
                    ? _color
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadTypeChip extends StatelessWidget {
  final LoadType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _LoadTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (type) {
      case LoadType.point:
        return 'Point Load';
      case LoadType.distributed:
        return 'Distributed';
      case LoadType.moment:
        return 'Moment';
    }
  }

  IconData get _icon {
    switch (type) {
      case LoadType.point:
        return Iconsax.arrow_down;
      case LoadType.distributed:
        return Iconsax.arrow_down_1;
      case LoadType.moment:
        return Iconsax.refresh;
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
              ? AppColors.accent.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
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
                  ? AppColors.accent
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 8),
            Text(
              _label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected
                    ? AppColors.accent
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

class _LoadValueInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _LoadValueInput({
    required this.controller,
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
              Iconsax.weight_1,
              size: 18,
              color: AppColors.accent,
            ),
            const SizedBox(width: 8),
            Text(
              'Load Value',
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
              hintText: 'Enter load value',
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
      ],
    );
  }
}

class _UnitSelector extends StatelessWidget {
  final LoadUnits selectedUnit;
  final Function(LoadUnits) onChanged;

  const _UnitSelector({
    required this.selectedUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit',
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LoadUnits>(
              value: selectedUnit,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              items: LoadUnits.values.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(
                    unit.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialProperty extends StatelessWidget {
  final String label;
  final String value;

  const _MaterialProperty({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Simple number input for AI params
class _AINumberInput extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final Function(double) onChanged;

  const _AINumberInput({
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
