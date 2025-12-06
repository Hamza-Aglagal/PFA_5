import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/models/notification.dart';

/// Toast Widget
class ToastWidget extends StatelessWidget {
  final ToastNotification toast;
  final VoidCallback? onDismiss;

  const ToastWidget({
    super.key,
    required this.toast,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(toast.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: toast.type.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: toast.type.color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: toast.type.color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: toast.type.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                toast.type.icon,
                color: toast.type.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                toast.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: toast.type.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (toast.actionLabel != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: toast.action,
                child: Text(
                  toast.actionLabel!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: toast.type.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                color: toast.type.color,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
      )
          .animate()
          .slideY(begin: -1, duration: 300.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 200.ms),
    );
  }
}

/// Toast Overlay Widget
class ToastOverlay extends StatelessWidget {
  final ToastNotification? toast;
  final VoidCallback? onDismiss;

  const ToastOverlay({
    super.key,
    this.toast,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (toast == null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: SafeArea(
        child: ToastWidget(
          toast: toast!,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}

/// Snackbar Helper
class SnackbarHelper {
  static void show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? action,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(type.icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: type.color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: duration,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: action ?? () {},
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context: context, message: message, type: NotificationType.success);
  }

  static void showError(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: NotificationType.error,
      duration: const Duration(seconds: 5),
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(context: context, message: message, type: NotificationType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context: context, message: message, type: NotificationType.info);
  }
}

/// Status Chip Widget
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isSmall;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 12 : 14,
              color: color,
            ),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            label,
            style: (isSmall ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
                .copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge Widget
class BadgeWidget extends StatelessWidget {
  final int count;
  final Color? color;
  final double size;
  final bool showZero;

  const BadgeWidget({
    super.key,
    required this.count,
    this.color,
    this.size = 18,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.6,
          ),
        ),
      ),
    );
  }
}

/// Badge on Icon
class IconWithBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;

  const IconWithBadge({
    super.key,
    required this.child,
    required this.count,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: BadgeWidget(
              count: count,
              color: badgeColor,
              size: 16,
            ),
          ),
      ],
    );
  }
}
