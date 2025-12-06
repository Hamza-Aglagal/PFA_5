import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int)? onStepTap;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).scaleX(begin: 0, alignment: Alignment.centerLeft),
            );
          }

          // Step circle
          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return GestureDetector(
            onTap: isCompleted ? () => onStepTap?.call(stepIndex) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 40 : 32,
                  height: isActive ? 40 : 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isActive
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight),
                      width: 2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : Text(
                            '${stepIndex + 1}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[stepIndex],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: (index * 100).ms).scale(begin: const Offset(0.8, 0.8)),
          );
        }),
      ),
    );
  }
}
