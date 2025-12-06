import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/simulation_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/simulation.dart';
import '../../../core/models/notification.dart';
import '../../../shared/widgets/modern_avatar.dart';
import '../../../shared/widgets/modern_buttons.dart';
import '../../../shared/widgets/modern_cards.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final simulationService = context.read<SimulationService>();
    
    if (authService.user != null) {
      await simulationService.initialize(authService.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = context.watch<AuthService>();
    final simulationService = context.watch<SimulationService>();
    final notificationService = context.watch<NotificationService>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, isDark, authService, notificationService),

                  const SizedBox(height: 24),

                  // Welcome Card
                  _buildWelcomeCard(context, isDark, simulationService),

                  const SizedBox(height: 24),

                  // Stats Grid
                  _buildStatsGrid(context, isDark, simulationService),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context, isDark),

                  const SizedBox(height: 24),

                  // Recent Simulations
                  _buildRecentSimulations(context, isDark, simulationService),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ModernFAB(
        icon: Iconsax.add,
        label: 'New',
        onPressed: () => context.push('/simulation'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AuthService authService,
    NotificationService notificationService,
  ) {
    return Row(
      children: [
        ModernAvatar(
          name: authService.user?.name ?? 'User',
          imageUrl: authService.user?.avatarUrl,
          size: AvatarSize.md,
          gradientIndex: 2,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your simulations',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.05),
        ModernIconButton(
          icon: Iconsax.notification,
          onPressed: () => _showNotificationsPanel(context, notificationService),
          hasBadge: notificationService.hasUnread,
          badgeCount: notificationService.unreadCount > 0 
              ? notificationService.unreadCount.toString() 
              : null,
          size: 48,
          backgroundColor: isDark 
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.08),
        ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isDark, SimulationService simulationService) {
    final totalSims = simulationService.totalSimulations;
    final completedSims = simulationService.completedCount;
    final completionRate = totalSims > 0 ? (completedSims / totalSims * 100).toInt() : 0;

    return GradientCard(
      gradient: AppColors.primaryGradient,
      animationDelay: 100,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedSims of $totalSims',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Simulations completed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalSims > 0 ? completedSims / totalSims : 0,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$completionRate%',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsPanel(BuildContext context, NotificationService notificationService) {
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
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Iconsax.notification5, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Notifications',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (notificationService.hasUnread)
                      SoftButton(
                        label: 'Mark all read',
                        color: AppColors.primary,
                        onPressed: () => notificationService.markAllAsRead(),
                      ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              // Notifications List
              Expanded(
                child: notificationService.notifications.isEmpty
                    ? EmptyStateWidget(
                        icon: Iconsax.notification,
                        title: 'No notifications yet',
                        subtitle: 'You\'re all caught up!',
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notificationService.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notificationService.notifications[index];
                          return _NotificationTile(
                            notification: notification,
                            onTap: () {
                              notificationService.markAsRead(notification.id);
                              if (notification.actionUrl != null) {
                                Navigator.pop(context);
                                context.push(notification.actionUrl!);
                              }
                            },
                            onDismiss: () {
                              notificationService.removeNotification(notification.id);
                            },
                          ).animate(delay: Duration(milliseconds: index * 50))
                              .fadeIn()
                              .slideX(begin: 0.05);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    bool isDark,
    SimulationService simulationService,
  ) {
    final safeSims = simulationService.simulations
        .where((s) => s.result?.status == ResultStatus.safe)
        .length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                value: simulationService.totalSimulations.toString(),
                label: 'Total Sims',
                icon: Iconsax.chart_215,
                color: AppColors.primary,
                animationDelay: 200,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ModernStatCard(
                value: simulationService.completedCount.toString(),
                label: 'Completed',
                icon: Iconsax.tick_circle5,
                color: AppColors.success,
                animationDelay: 250,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                value: safeSims.toString(),
                label: 'Safe Designs',
                icon: Iconsax.shield_tick5,
                color: AppColors.accent,
                animationDelay: 300,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ModernStatCard(
                value: simulationService.favoriteSimulations.length.toString(),
                label: 'Favorites',
                icon: Iconsax.star5,
                color: AppColors.warning,
                animationDelay: 350,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.titleMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ).animate(delay: 400.ms).fadeIn(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickActionButton(
              icon: Iconsax.add_circle5,
              label: 'New',
              color: AppColors.primary,
              onTap: () => context.push('/simulation'),
              animationDelay: 450,
            ),
            QuickActionButton(
              icon: Iconsax.clock5,
              label: 'History',
              color: AppColors.secondary,
              onTap: () => context.go('/history'),
              animationDelay: 500,
            ),
            QuickActionButton(
              icon: Iconsax.document_upload5,
              label: 'Share',
              color: AppColors.accent,
              onTap: () => context.go('/community'),
              animationDelay: 550,
            ),
            QuickActionButton(
              icon: Iconsax.setting_25,
              label: 'Settings',
              color: AppColors.purple,
              onTap: () => context.go('/profile'),
              animationDelay: 600,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSimulations(
    BuildContext context,
    bool isDark,
    SimulationService simulationService,
  ) {
    final recentSimulations = simulationService.recentSimulations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Simulations',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            SoftButton(
              label: 'See All',
              color: AppColors.primary,
              icon: Iconsax.arrow_right_3,
              onPressed: () => context.go('/history'),
            ),
          ],
        ).animate(delay: 650.ms).fadeIn(),

        const SizedBox(height: 16),

        if (recentSimulations.isEmpty)
          _buildEmptyState(context, isDark)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSimulations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final simulation = recentSimulations[index];
              return _ModernSimulationCard(
                simulation: simulation,
                onTap: () {
                  if (simulation.hasResult) {
                    context.push('/results/${simulation.id}');
                  } else {
                    simulationService.loadSimulation(simulation.id);
                    context.push('/simulation');
                  }
                },
                onFavorite: () => simulationService.toggleFavorite(simulation.id),
                onMenu: () => _showSimulationMenu(context, simulation, simulationService),
              ).animate(delay: Duration(milliseconds: 700 + index * 80))
                  .fadeIn()
                  .slideY(begin: 0.05);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      animationDelay: 700,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.softGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.chart_2,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No simulations yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first structural analysis',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Create Simulation',
            icon: Iconsax.add,
            onPressed: () => context.push('/simulation'),
            isExpanded: false,
          ),
        ],
      ),
    );
  }

  void _showSimulationMenu(
    BuildContext context,
    Simulation simulation,
    SimulationService simulationService,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                simulation.name,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _MenuTile(
              icon: Iconsax.edit_2,
              title: 'Edit Simulation',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                simulationService.loadSimulation(simulation.id);
                context.push('/simulation');
              },
            ),
            _MenuTile(
              icon: Iconsax.copy,
              title: 'Duplicate',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                simulationService.duplicateSimulation(simulation);
              },
            ),
            _MenuTile(
              icon: Iconsax.share,
              title: 'Share',
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _MenuTile(
              icon: Iconsax.trash,
              title: 'Delete',
              color: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await _showDeleteConfirmation(context);
                if (confirm == true) {
                  simulationService.deleteSimulation(simulation.id);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.trash, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Simulation',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this simulation? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          SecondaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            isExpanded: false,
            height: 44,
          ),
          const SizedBox(width: 8),
          PrimaryButton(
            label: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            isExpanded: false,
            height: 44,
            gradient: const LinearGradient(
              colors: [AppColors.error, Color(0xFFFF6B6B)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernSimulationCard extends StatelessWidget {
  final Simulation simulation;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onMenu;

  const _ModernSimulationCard({
    required this.simulation,
    required this.onTap,
    required this.onFavorite,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    simulation.status.color.withValues(alpha: 0.2),
                    simulation.status.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                simulation.params.structureType.iconData,
                color: simulation.status.color,
                size: 26,
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
                          simulation.name,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: simulation.status.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          simulation.status.displayName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: simulation.status.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 14,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        simulation.timeAgo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        simulation.params.structureType.iconData,
                        size: 14,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        simulation.params.structureType.displayName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                GestureDetector(
                  onTap: onFavorite,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: simulation.isFavorite
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      simulation.isFavorite ? Iconsax.star5 : Iconsax.star,
                      color: simulation.isFavorite
                          ? AppColors.warning
                          : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onMenu,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Iconsax.more,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        size: 18,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                notification.type.color.withValues(alpha: 0.2),
                notification.type.color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            notification.category.icon,
            color: notification.type.color,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification.message,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              notification.timeAgo,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
