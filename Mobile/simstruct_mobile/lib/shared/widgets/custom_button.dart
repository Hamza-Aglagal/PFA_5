import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Button Type
enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  gradient,
}

/// Button Size
enum ButtonSize {
  small,
  medium,
  large,
}

/// Custom Button Widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: _height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _backgroundColor(isDark),
            foregroundColor: _foregroundColor(isDark),
            elevation: type == ButtonType.ghost ? 0 : 2,
            shadowColor: _backgroundColor(isDark).withValues(alpha: 0.3),
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              side: type == ButtonType.outline
                  ? BorderSide(
                      color: isDark ? AppColors.primary : AppColors.primary,
                      width: 1.5,
                    )
                  : BorderSide.none,
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              _foregroundColor(isDark).withValues(alpha: 0.1),
            ),
          ),
          child: isLoading ? _buildLoadingIndicator() : _buildContent(),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.95, 0.95),
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildContent() {
    final children = <Widget>[
      if (icon != null && !iconRight) ...[
        Icon(icon, size: _iconSize),
        SizedBox(width: size == ButtonSize.small ? 6 : 8),
      ],
      Text(
        text,
        style: _textStyle,
      ),
      if (icon != null && iconRight) ...[
        SizedBox(width: size == ButtonSize.small ? 6 : 8),
        Icon(icon, size: _iconSize),
      ],
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: _iconSize,
      height: _iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor(false)),
      ),
    );
  }

  double get _height {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double get _iconSize {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600);
    }
  }

  Color _backgroundColor(bool isDark) {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.ghost:
        return Colors.transparent;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.gradient:
        return AppColors.primary;
    }
  }

  Color _foregroundColor(bool isDark) {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.ghost:
        return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.gradient:
        return Colors.white;
    }
  }
}

/// Icon Button with Background
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool isLoading;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.tooltip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final iconColor = color ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size + 20,
          height: size + 20,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: size * 0.8,
                  height: size * 0.8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : Icon(icon, size: size, color: iconColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Floating Action Button
class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool extended;

  const CustomFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(icon),
        label: Text(label!),
      ).animate().scale(
            begin: const Offset(0, 0),
            duration: 300.ms,
            curve: Curves.elasticOut,
          );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: Icon(icon),
    ).animate().scale(
          begin: const Offset(0, 0),
          duration: 300.ms,
          curve: Curves.elasticOut,
        );
  }
}
