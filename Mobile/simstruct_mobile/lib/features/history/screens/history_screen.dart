import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/simulation.dart';
import '../../../core/models/simulation_params.dart';
import '../../../core/services/simulation_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/modern_buttons.dart';
import '../../../shared/widgets/modern_cards.dart';
import '../../../shared/widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  bool _isLoading = false;

  final _filters = ['All', 'Completed', 'In Progress', 'Failed'];
  final _sortOptions = ['Newest', 'Oldest', 'Name A-Z', 'Name Z-A'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSimulations();
    });
  }

  Future<void> _loadSimulations() async {
    final authService = context.read<AuthService>();
    final simulationService = context.read<SimulationService>();
    
    if (authService.user != null) {
      setState(() => _isLoading = true);
      await simulationService.loadSimulations(authService.user!.id);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Simulation> _filterSimulations(List<Simulation> simulations) {
    var filtered = simulations.where((s) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!s.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Status filter
      switch (_selectedFilter) {
        case 'Completed':
          return s.status == SimulationStatus.completed;
        case 'In Progress':
          return s.status == SimulationStatus.running;
        case 'Failed':
          return s.status == SimulationStatus.failed;
        default:
          return true;
      }
    }).toList();

    // Sort
    switch (_selectedSort) {
      case 'Oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Name A-Z':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name Z-A':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final simulationService = context.watch<SimulationService>();
    final simulations = _filterSimulations(simulationService.simulations);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _loadSimulations,
        color: AppColors.primary,
        child: _isLoading && simulations.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'History',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${simulations.length} simulation${simulations.length != 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() => _isGridView = !_isGridView);
                },
                icon: Icon(
                  _isGridView ? Iconsax.element_3 : Iconsax.grid_2,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search and Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search simulations...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                        prefixIcon: const Icon(
                          Iconsax.search_normal,
                          color: AppColors.primary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  size: 20,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1),

                  const SizedBox(height: 16),

                  // Filters Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              final isSelected = filter == _selectedFilter;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedFilter = filter),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.cardDark
                                            : AppColors.cardLight),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.dividerDark
                                              : AppColors.dividerLight),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      filter,
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PopupMenuButton<String>(
                        onSelected: (value) =>
                            setState(() => _selectedSort = value),
                        itemBuilder: (context) => _sortOptions
                            .map((option) => PopupMenuItem(
                                  value: option,
                                  child: Row(
                                    children: [
                                      if (option == _selectedSort)
                                        const Icon(
                                          Icons.check,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      if (option == _selectedSort)
                                        const SizedBox(width: 8),
                                      Text(option),
                                    ],
                                  ),
                                ))
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.sort,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedSort,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate(delay: 100.ms).fadeIn(),
                ],
              ),
            ),
          ),

          // Content
          if (simulations.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                hasFilter: _selectedFilter != 'All' ||
                    _searchController.text.isNotEmpty,
              ),
            )
          else if (_isGridView)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final simulation = simulations[index];
                    return _SimulationGridCard(
                      simulation: simulation,
                      onTap: () => context.go('/results/${simulation.id}'),
                      onDelete: () => _deleteSimulation(simulation),
                      onFavorite: () => _toggleFavorite(simulation),
                      onDuplicate: () => _duplicateSimulation(simulation),
                      onShare: () => _shareSimulation(simulation),
                    ).animate(delay: (index * 50).ms).fadeIn().scale(
                          begin: const Offset(0.95, 0.95),
                        );
                  },
                  childCount: simulations.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final simulation = simulations[index];
                    return _SimulationListCard(
                      simulation: simulation,
                      onTap: () => context.go('/results/${simulation.id}'),
                      onDelete: () => _deleteSimulation(simulation),
                      onFavorite: () => _toggleFavorite(simulation),
                      onDuplicate: () => _duplicateSimulation(simulation),
                      onShare: () => _shareSimulation(simulation),
                    ).animate(delay: (index * 50).ms).fadeIn().slideX(
                          begin: 0.05,
                        );
                  },
                  childCount: simulations.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
      ), // Close RefreshIndicator
    );
  }

  void _deleteSimulation(Simulation simulation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Simulation'),
        content: Text('Are you sure you want to delete "${simulation.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<SimulationService>().deleteSimulation(simulation.id);
    }
  }

  void _toggleFavorite(Simulation simulation) {
    context.read<SimulationService>().toggleFavorite(simulation.id);
  }

  void _duplicateSimulation(Simulation simulation) {
    final simulationService = context.read<SimulationService>();
    final newSimulation = simulationService.duplicateSimulation(simulation);
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicated as "${newSimulation.name}"'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.go('/results/${newSimulation.id}'),
        ),
      ),
    );
  }

  void _shareSimulation(Simulation simulation) async {
    final communityService = context.read<CommunityService>();
    
    // Load friends if not already loaded
    if (communityService.friends.isEmpty) {
      await communityService.loadFriends(null);
    }
    
    // Show share options dialog
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSimulationDialog(simulation: simulation),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;

  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilter ? Iconsax.search_status : Iconsax.document,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasFilter ? 'No results found' : 'No simulations yet',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Try adjusting your filters'
                : 'Create your first simulation to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (!hasFilter) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: 'New Simulation',
              onPressed: () => context.go('/simulation'),
              icon: Icons.add_rounded,
            ),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}

class _SimulationListCard extends StatelessWidget {
  final Simulation simulation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;

  const _SimulationListCard({
    required this.simulation,
    required this.onTap,
    required this.onDelete,
    required this.onFavorite,
    required this.onDuplicate,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(simulation.status).withValues(alpha: 0.15),
                    _getStatusColor(simulation.status).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getStructureIcon(simulation.params.structureType),
                color: _getStatusColor(simulation.status),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    simulation.name,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatusChip(status: simulation.status),
                      const SizedBox(width: 10),
                      Icon(
                        Iconsax.clock,
                        size: 12,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(simulation.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Safety Factor
            if (simulation.result != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getResultColor(simulation.result!.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      simulation.result!.safetyFactor.toStringAsFixed(1),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _getResultColor(simulation.result!.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SF',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getResultColor(simulation.result!.status)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Menu
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onTap,
                  child: const Row(
                    children: [
                      Icon(Iconsax.eye, size: 18),
                      SizedBox(width: 8),
                      Text('View'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onFavorite,
                  child: Row(
                    children: [
                      Icon(simulation.isFavorite ? Iconsax.heart5 : Iconsax.heart, size: 18, color: simulation.isFavorite ? AppColors.error : null),
                      const SizedBox(width: 8),
                      Text(simulation.isFavorite ? 'Remove Favorite' : 'Add Favorite'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onDuplicate,
                  child: const Row(
                    children: [
                      Icon(Iconsax.copy, size: 18),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onShare,
                  child: const Row(
                    children: [
                      Icon(Iconsax.share, size: 18),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: const Row(
                    children: [
                      Icon(Iconsax.trash, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SimulationStatus status) {
    switch (status) {
      case SimulationStatus.completed:
        return AppColors.success;
      case SimulationStatus.running:
        return AppColors.info;
      case SimulationStatus.failed:
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  Color _getResultColor(ResultStatus status) {
    switch (status) {
      case ResultStatus.safe:
        return AppColors.success;
      case ResultStatus.warning:
        return AppColors.warning;
      case ResultStatus.critical:
        return AppColors.error;
    }
  }

  IconData _getStructureIcon(StructureType type) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SimulationGridCard extends StatelessWidget {
  final Simulation simulation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;

  const _SimulationGridCard({
    required this.simulation,
    required this.onTap,
    required this.onDelete,
    required this.onFavorite,
    required this.onDuplicate,
    required this.onShare,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(simulation.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStructureIcon(simulation.params.structureType),
                    color: _getStatusColor(simulation.status),
                    size: 22,
                  ),
                ),
                _StatusChip(status: simulation.status),
              ],
            ),
            const Spacer(),
            Text(
              simulation.name,
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${simulation.params.structureType.displayName} • ${simulation.params.material.displayName}',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (simulation.result != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getResultColor(simulation.result!.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SF: ${simulation.result!.safetyFactor.toStringAsFixed(1)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getResultColor(simulation.result!.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                Text(
                  _formatDate(simulation.createdAt),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SimulationStatus status) {
    switch (status) {
      case SimulationStatus.completed:
        return AppColors.success;
      case SimulationStatus.running:
        return AppColors.info;
      case SimulationStatus.failed:
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  Color _getResultColor(ResultStatus status) {
    switch (status) {
      case ResultStatus.safe:
        return AppColors.success;
      case ResultStatus.warning:
        return AppColors.warning;
      case ResultStatus.critical:
        return AppColors.error;
    }
  }

  IconData _getStructureIcon(StructureType type) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${date.day}/${date.month}';
  }
}

class _StatusChip extends StatelessWidget {
  final SimulationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getText(),
        style: AppTextStyles.labelSmall.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case SimulationStatus.completed:
        return AppColors.success;
      case SimulationStatus.running:
        return AppColors.info;
      case SimulationStatus.failed:
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  String _getText() {
    switch (status) {
      case SimulationStatus.completed:
        return 'Completed';
      case SimulationStatus.running:
        return 'Running';
      case SimulationStatus.failed:
        return 'Failed';
      default:
        return 'Pending';
    }
  }
}

/// Share Simulation Dialog
class _ShareSimulationDialog extends StatefulWidget {
  final Simulation simulation;

  const _ShareSimulationDialog({required this.simulation});

  @override
  State<_ShareSimulationDialog> createState() => _ShareSimulationDialogState();
}

class _ShareSimulationDialogState extends State<_ShareSimulationDialog> {
  bool _isSharing = false;
  String? _selectedFriendId;

  Future<void> _shareWithFriend(Friend friend) async {
    setState(() => _isSharing = true);

    try {
      final communityService = context.read<CommunityService>();
      final notificationService = context.read<NotificationService>();

      final success = await communityService.shareSimulation(
        simulation: widget.simulation,
        friendId: friend.id,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (success) {
        notificationService.showSuccess(
          'Simulation shared with ${friend.name}!',
        );
      } else {
        notificationService.showError(
          communityService.error ?? 'Failed to share simulation',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        context.read<NotificationService>().showError(
          'Failed to share simulation',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _makePublic() async {
    setState(() => _isSharing = true);

    try {
      final simulationService = context.read<SimulationService>();
      final notificationService = context.read<NotificationService>();

      await simulationService.togglePublicOnBackend(widget.simulation.id);

      if (!mounted) return;

      Navigator.pop(context);
      notificationService.showSuccess(
        'Simulation is now public and visible in Community!',
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        context.read<NotificationService>().showError(
          'Failed to make simulation public',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final communityService = context.watch<CommunityService>();
    final friends = communityService.friends;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.share,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Simulation',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.simulation.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Make Public Option
            ListTile(
              onTap: _isSharing ? null : _makePublic,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.global,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              title: const Text('Make Public'),
              subtitle: const Text('Anyone can view in Community'),
              trailing: widget.simulation.isPublic
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : const Icon(Iconsax.arrow_right_3),
            ),

            const Divider(height: 1),

            // Share with Friends Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Share with Friends',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${friends.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Friends List
            Expanded(
              child: _isSharing
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Sharing simulation...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : friends.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.user,
                                size: 48,
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No friends yet',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add friends to share simulations',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: friends.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return ListTile(
                              onTap: () => _shareWithFriend(friend),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(friend.name),
                              subtitle: Text(friend.email),
                              trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
