import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/notification.dart';

/// App Wrapper - Handles global overlays like connectivity banner and toasts
class AppWrapper extends StatefulWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize connectivity check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectivityService>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    final notifications = context.watch<NotificationService>();

    return Stack(
      children: [
        widget.child,
        
        // Connection Status Banner
        _ConnectionBanner(status: connectivity.status),
        
        // Toast Notifications Overlay
        if (notifications.currentToast != null)
          _ToastOverlay(
            toast: notifications.currentToast!,
            onDismiss: () => notifications.dismissToast(),
          ),
      ],
    );
  }
}

/// Connection Status Banner
class _ConnectionBanner extends StatelessWidget {
  final ConnectionStatus status;

  const _ConnectionBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == ConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    final isChecking = status == ConnectionStatus.checking;
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        offset: Offset(0, status == ConnectionStatus.connected ? -1 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.only(
            top: mediaQuery.padding.top + 8,
            bottom: 12,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            gradient: isChecking
                ? LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withValues(alpha: 0.9),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.error,
                      AppColors.error.withValues(alpha: 0.9),
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: (isChecking ? AppColors.warning : AppColors.error)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (isChecking)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Iconsax.wifi_square,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isChecking ? 'Checking Connection...' : 'No Internet Connection',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isChecking)
                        Text(
                          'Please check your network settings',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isChecking)
                  GestureDetector(
                    onTap: () => context.read<ConnectivityService>().refresh(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.refresh, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Retry',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.5),
    );
  }
}

/// Toast Overlay - Dark themed for better visibility
class _ToastOverlay extends StatelessWidget {
  final ToastNotification toast;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.toast,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + 16,
      left: 16,
      right: 16,
      child: Dismissible(
        key: Key(toast.id),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => onDismiss(),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Dark background for better visibility
              color: const Color(0xFF1E2128),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: toast.type.color.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: toast.type.color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        toast.type.color,
                        toast.type.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: toast.type.color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    toast.type.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        toast.title ?? _getDefaultTitle(toast.type),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toast.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (toast.actionLabel != null)
                  GestureDetector(
                    onTap: () {
                      toast.action?.call();
                      onDismiss();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: toast.type.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        toast.actionLabel!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.3, curve: Curves.easeOutCubic),
      ),
    );
  }

  String _getDefaultTitle(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return 'Success';
      case NotificationType.error:
        return 'Error';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.info:
        return 'Information';
    }
  }
}

/// Welcome Dialog
class WelcomeDialog extends StatelessWidget {
  final String userName;
  final VoidCallback onDismiss;

  const WelcomeDialog({
    super.key,
    required this.userName,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = userName.split(' ').first;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.floatingShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Welcome Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.copperGlowShadow,
              ),
              child: const Icon(
                Iconsax.user_tick5,
                color: Colors.white,
                size: 40,
              ),
            ).animate().scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 24),
            
            Text(
              'Welcome Back! 👋',
              style: AppTextStyles.headlineSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: 8),
            
            Text(
              'Hello $firstName, great to see you again!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ).animate(delay: 300.ms).fadeIn(),
            
            const SizedBox(height: 8),
            
            Text(
              'Ready to analyze some structures?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ).animate(delay: 400.ms).fadeIn(),
            
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WelcomeStat(
                  icon: Iconsax.document,
                  value: '5',
                  label: 'Simulations',
                  delay: 500,
                ),
                _WelcomeStat(
                  icon: Iconsax.people,
                  value: '12',
                  label: 'Connections',
                  delay: 600,
                ),
                _WelcomeStat(
                  icon: Iconsax.medal_star,
                  value: 'Pro',
                  label: 'Status',
                  delay: 700,
                ),
              ],
            ),
            
            const SizedBox(height: 28),
            
            // Continue Button
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.primaryShadow,
                ),
                child: Center(
                  child: Text(
                    'Let\'s Go!',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final int delay;

  const _WelcomeStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
        ),
      ],
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().scale(begin: const Offset(0.8, 0.8));
  }
}

/// Connection Restored Overlay (shows briefly when connection is restored)
class ConnectionRestoredOverlay extends StatelessWidget {
  const ConnectionRestoredOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.wifi, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(
            'Connection Restored',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
