import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/simulation_params.dart';
import '../../../core/models/notification.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/modern_avatar.dart';
import '../../../shared/widgets/modern_buttons.dart';
import '../../../shared/widgets/modern_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNotificationsBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Consumer<NotificationService>(
                          builder: (context, service, _) => service.hasUnread
                              ? TextButton(
                                  onPressed: () => service.markAllAsRead(),
                                  child: Text(
                                    'Mark all read',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Notifications List
              Expanded(
                child: Consumer<NotificationService>(
                  builder: (context, notificationService, _) {
                    final notifications = notificationService.notifications;
                    
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.notification,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Notifications',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You\'re all caught up!',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _NotificationItem(
                          notification: notification,
                          isDark: isDark,
                          onTap: () {
                            notificationService.markAsRead(notification.id);
                          },
                          onDismiss: () {
                            notificationService.removeNotification(notification.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthService>().user;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context, isDark, user?.name ?? 'Engineer', user?.avatarUrl),

              const SizedBox(height: 8),

              // Hero Section
              _buildHeroSection(context, isDark),

              const SizedBox(height: 28),

              // Quick Actions
              _buildQuickActions(context, isDark),

              const SizedBox(height: 28),

              // Features Section
              _buildFeaturesSection(context, isDark),

              const SizedBox(height: 28),

              // Structure Types Section
              _buildStructureTypesSection(context, isDark),

              const SizedBox(height: 28),

              // Stats Section
              _buildStatsSection(context, isDark),

              const SizedBox(height: 28),

              // How It Works
              _buildHowItWorksSection(context, isDark),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, String name, String? avatarUrl) {
    final firstName = name.split(' ').first;
    final notificationService = context.watch<NotificationService>();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Avatar with greeting
          ModernAvatar(
            name: name,
            imageUrl: avatarUrl,
            size: AvatarSize.md,
            showOnlineIndicator: true,
            isOnline: true,
            gradientIndex: 0,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
                const SizedBox(height: 2),
                Text(
                  firstName,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.05),
              ],
            ),
          ),
          // Notification Button
          ModernIconButton(
            icon: Iconsax.notification,
            onPressed: () => _showNotificationsBottomSheet(context),
            hasBadge: notificationService.hasUnread,
            badgeCount: notificationService.unreadCount > 9 
                ? '9+' 
                : '${notificationService.unreadCount}',
            size: 48,
            backgroundColor: isDark 
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.08),
          ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  Widget _buildHeroSection(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.cpu, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'AI-Powered',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Structural\nAnalysis',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),
                Text(
                  'Analyze stability with precision.\nGet AI insights for your projects.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.push('/simulation'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.play_circle5, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Start Simulation',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            icon: Iconsax.add_square5,
            label: 'New',
            color: AppColors.primary,
            onTap: () => context.push('/simulation'),
            animationDelay: 0,
          ),
          QuickActionButton(
            icon: Iconsax.clock5,
            label: 'History',
            color: AppColors.secondary,
            onTap: () => context.go('/history'),
            animationDelay: 100,
          ),
          QuickActionButton(
            icon: Iconsax.people5,
            label: 'Community',
            color: AppColors.accent,
            onTap: () => context.go('/community'),
            animationDelay: 200,
          ),
          QuickActionButton(
            icon: Iconsax.chart_215,
            label: 'Dashboard',
            color: AppColors.purple,
            onTap: () => context.go('/dashboard'),
            animationDelay: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Why SimStruct?', isDark, delay: 200),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FeatureCard(
                  icon: Iconsax.flash_15,
                  title: 'Fast',
                  subtitle: 'Instant results',
                  color: AppColors.primary,
                  animationDelay: 300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FeatureCard(
                  icon: Iconsax.cpu5,
                  title: 'Smart AI',
                  subtitle: 'Recommendations',
                  color: AppColors.secondary,
                  animationDelay: 400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FeatureCard(
                  icon: Iconsax.shield_tick5,
                  title: 'Precise',
                  subtitle: '99.9% accuracy',
                  color: AppColors.success,
                  animationDelay: 500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStructureTypesSection(BuildContext context, bool isDark) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.purple,
    ];

    final gradients = [
      AppColors.primaryGradient,
      AppColors.secondaryGradient,
      AppColors.accentGradient,
      AppColors.heroGradient,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Structure Types', isDark, delay: 400),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: StructureType.values.length,
              itemBuilder: (context, index) {
                final type = StructureType.values[index];
                return GestureDetector(
                  onTap: () => context.push('/simulation'),
                  child: Container(
                    width: 140,
                    margin: EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      gradient: gradients[index % gradients.length],
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors[index % colors.length].withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            type.iconData,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  type.iconData,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                type.displayName,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: 500 + index * 80))
                    .fadeIn()
                    .slideX(begin: 0.15, curve: Curves.easeOutCubic);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Platform Stats', isDark, delay: 600),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernStatCard(
                  value: '10K+',
                  label: 'Simulations',
                  icon: Iconsax.chart_215,
                  color: AppColors.primary,
                  trend: '+12%',
                  isPositive: true,
                  animationDelay: 700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ModernStatCard(
                  value: '2.5K+',
                  label: 'Engineers',
                  icon: Iconsax.people5,
                  color: AppColors.secondary,
                  trend: '+8%',
                  isPositive: true,
                  animationDelay: 800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ModernStatCard(
                  value: '99.9%',
                  label: 'Accuracy',
                  icon: Iconsax.verify5,
                  color: AppColors.success,
                  animationDelay: 900,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ModernStatCard(
                  value: '45+',
                  label: 'Countries',
                  icon: Iconsax.global5,
                  color: AppColors.accent,
                  animationDelay: 1000,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context, bool isDark) {
    final steps = [
      _StepItem(icon: Iconsax.edit_25, title: 'Define', description: 'Set parameters'),
      _StepItem(icon: Iconsax.setting_45, title: 'Configure', description: 'Materials & loads'),
      _StepItem(icon: Iconsax.cpu5, title: 'Analyze', description: 'AI processing'),
      _StepItem(icon: Iconsax.chart_success5, title: 'Results', description: 'Get insights'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('How It Works', isDark, delay: 1000),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(20),
            animationDelay: 1100,
            child: Column(
              children: steps.asMap().entries.map((entry) {
                final isLast = entry.key == steps.length - 1;
                return _buildStepItem(entry.value, entry.key, isDark, isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(_StepItem step, int index, bool isDark, bool isLast) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.success];
    final color = colors[index % colors.length];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(step.icon, color: Colors.white, size: 24),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.5),
                      colors[(index + 1) % colors.length].withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate(delay: Duration(milliseconds: 1200 + index * 100))
        .fadeIn()
        .slideX(begin: -0.05);
  }

  Widget _buildSectionHeader(String title, bool isDark, {int delay = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: -0.03);
  }
}

class _StepItem {
  final IconData icon;
  final String title;
  final String description;

  const _StepItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Notification item for bottom sheet
class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationItem({
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.1),
        child: const Icon(Iconsax.trash, color: AppColors.error),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.transparent
                  : (isDark
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : AppColors.primary.withValues(alpha: 0.03)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        notification.type.color,
                        notification.type.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: notification.type.color.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    notification.category.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            notification.timeAgo,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8, top: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
