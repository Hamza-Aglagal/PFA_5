import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/simulation.dart';
import '../../../core/services/simulation_service.dart';
import '../../../shared/widgets/widgets.dart';

class ResultsScreen extends StatefulWidget {
  final String simulationId;

  const ResultsScreen({
    super.key,
    required this.simulationId,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Simulation? _simulation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSimulation();
    });
  }

  Future<void> _loadSimulation() async {
    final simulationService = context.read<SimulationService>();
    
    // First try to get by ID locally
    _simulation = simulationService.getSimulationById(widget.simulationId);
    
    // If not found locally, try to get the current simulation (useful after running a new simulation)
    _simulation ??= simulationService.currentSimulation;
    
    // If still not found, try loading from backend
    if (_simulation == null) {
      await simulationService.getSimulationFromBackend(widget.simulationId);
      _simulation = simulationService.getSimulationById(widget.simulationId);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final simulationService = context.watch<SimulationService>();
    
    // Show loading while fetching
    if (_isLoading) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    
    // Re-check for simulation if still null
    if (_simulation == null) {
      _simulation = simulationService.getSimulationById(widget.simulationId);
      _simulation ??= simulationService.currentSimulation;
    }

    if (_simulation == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: CustomAppBar(
          title: 'Results',
          onBack: () => context.go('/dashboard'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.document_text,
                size: 64,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Simulation not found',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The simulation may have been deleted or moved.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Iconsax.home),
                label: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final result = _simulation!.result;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // App Bar with green gradient header
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: _getStatusColor(result?.status),
              leading: IconButton(
                onPressed: () => context.go('/dashboard'),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // Share functionality
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.share,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Export functionality
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.document_download,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(result?.status).withValues(alpha: 0.95),
                        _getStatusColor(result?.status).withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(result?.status),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusText(result?.status),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideX(begin: -0.2),
                          const SizedBox(height: 12),

                          // Simulation Name
                          Text(
                            _simulation!.name,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2),
                          const SizedBox(height: 8),

                          // Structure Info
                          Row(
                            children: [
                              _InfoChip(
                                icon: Iconsax.building,
                                label: _simulation!.params.structureType.displayName,
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Iconsax.layer,
                                label: _simulation!.params.material.displayName,
                              ),
                            ],
                          ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.2),
                          const SizedBox(height: 16),

                          // Safety Factor
                          Row(
                            children: [
                              _SafetyFactorCircle(
                                value: result?.safetyFactor ?? 0,
                                status: result?.status,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Safety Factor',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getSafetyDescription(result?.safetyFactor),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // TabBar positioned BELOW the green header
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Details'),
                    Tab(text: 'AI Insights'),
                  ],
                ),
                isDark: isDark,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(simulation: _simulation!),
              _DetailsTab(simulation: _simulation!),
              _AIInsightsTab(simulation: _simulation!),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ResultStatus? status) {
    switch (status) {
      case ResultStatus.safe:
        return AppColors.success;
      case ResultStatus.warning:
        return AppColors.warning;
      case ResultStatus.critical:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(ResultStatus? status) {
    switch (status) {
      case ResultStatus.safe:
        return Iconsax.shield_tick;
      case ResultStatus.warning:
        return Iconsax.warning_2;
      case ResultStatus.critical:
        return Iconsax.danger;
      default:
        return Iconsax.info_circle;
    }
  }

  String _getStatusText(ResultStatus? status) {
    switch (status) {
      case ResultStatus.safe:
        return 'Safe Structure';
      case ResultStatus.warning:
        return 'Needs Attention';
      case ResultStatus.critical:
        return 'Critical Issue';
      default:
        return 'Analysis Complete';
    }
  }

  String _getSafetyDescription(double? factor) {
    if (factor == null) return 'Unable to determine';
    if (factor >= 2.0) return 'Excellent safety margin';
    if (factor >= 1.5) return 'Good safety margin';
    if (factor >= 1.0) return 'Minimum safety achieved';
    return 'Below safety threshold';
  }
}

/// Sliver TabBar Delegate for pinned tab bar below the header
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _SliverTabBarDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || isDark != oldDelegate.isDark;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label.replaceFirst(label[0], label[0].toUpperCase()),
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyFactorCircle extends StatelessWidget {
  final double value;
  final ResultStatus? status;

  const _SafetyFactorCircle({
    required this.value,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.headlineMedium.copyWith(
                color: _getStatusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'SF',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ResultStatus? status) {
    switch (status) {
      case ResultStatus.safe:
        return AppColors.success;
      case ResultStatus.warning:
        return AppColors.warning;
      case ResultStatus.critical:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

class _OverviewTab extends StatelessWidget {
  final Simulation simulation;

  const _OverviewTab({required this.simulation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = simulation.result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _MetricCard(
                title: 'Max Stress',
                value: '${result?.maxStress.toStringAsFixed(1) ?? '0'} MPa',
                icon: Iconsax.chart_21,
                color: AppColors.secondary,
              ),
              _MetricCard(
                title: 'Max Deflection',
                value: '${result?.maxDeflection.toStringAsFixed(2) ?? '0'} mm',
                icon: Iconsax.chart_1,
                color: AppColors.accent,
              ),
              _MetricCard(
                title: 'Buckling Load',
                value: '${result?.bucklingLoad.toStringAsFixed(1) ?? '0'} kN',
                icon: Iconsax.diagram,
                color: AppColors.info,
              ),
              _MetricCard(
                title: 'Nat. Frequency',
                value: '${result?.naturalFrequency.toStringAsFixed(2) ?? '0'} Hz',
                icon: Iconsax.clock,
                color: AppColors.success,
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Iconsax.document_download,
                  label: 'Export PDF',
                  color: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Iconsax.share,
                  label: 'Share',
                  color: AppColors.secondary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Iconsax.copy,
                  label: 'Duplicate',
                  color: AppColors.accent,
                  onTap: () {},
                ),
              ),
            ],
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 24),

          // Recommendations Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.lamp_on,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Top Recommendation',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result?.recommendations.firstOrNull ?? 'Analysis complete. Review detailed insights for recommendations.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final Simulation simulation;

  const _DetailsTab({required this.simulation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final params = simulation.params;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Structure Parameters
          _DetailSection(
            title: 'Structure Parameters',
            icon: Iconsax.building,
            items: [
              _DetailItem(label: 'Type', value: params.structureType.displayName),
              _DetailItem(label: 'Support', value: params.supportType.displayName),
              _DetailItem(
                label: 'Dimensions',
                value: '${params.length} × ${params.width} × ${params.height} ${params.dimensionUnits.symbol}',
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 20),

          // Material Properties
          _DetailSection(
            title: 'Material Properties',
            icon: Iconsax.layer,
            items: [
              _DetailItem(label: 'Material', value: params.material.displayName),
              _DetailItem(label: 'Load Type', value: params.loadType.displayName),
              _DetailItem(
                label: 'Load Value',
                value: '${params.loadValue} ${params.loadUnits.symbol}',
              ),
            ],
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 20),

          // Analysis Results
          Text(
            'Analysis Results',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 16),

          // Stress Distribution Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.3),
                  AppColors.warning.withValues(alpha: 0.3),
                  AppColors.error.withValues(alpha: 0.3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.chart_21,
                    size: 48,
                    color: isDark ? Colors.white70 : Colors.black45,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stress Distribution',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? Colors.white70 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_DetailItem> items;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
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
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      item.value.replaceFirst(item.value[0], item.value[0].toUpperCase()),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });
}

class _AIInsightsTab extends StatelessWidget {
  final Simulation simulation;

  const _AIInsightsTab({required this.simulation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = simulation.result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Analysis Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.cpu,
                    color: AppColors.accent,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI-Powered Analysis',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Intelligent recommendations based on your structure',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),

          // Recommendations
          Text(
            'Recommendations',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 16),

          if (result?.recommendations != null && result!.recommendations.isNotEmpty)
            ...result.recommendations.asMap().entries.map((entry) {
              return _RecommendationCard(
                index: entry.key + 1,
                text: entry.value,
              ).animate(delay: (150 + entry.key * 50).ms).fadeIn().slideX(begin: 0.1);
            }),

          const SizedBox(height: 24),

          // Ask AI Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Iconsax.message_question,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ask AI Assistant',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ask a question about this analysis...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Iconsax.send_1,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final int index;
  final String text;

  const _RecommendationCard({
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
