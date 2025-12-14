import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/simulation_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/simulation_params.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/step_indicator.dart';
import '../widgets/structure_step.dart';
import '../widgets/dimensions_step.dart';
import '../widgets/material_step.dart';
import '../widgets/review_step.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _nameController = TextEditingController();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final simulationService = context.read<SimulationService>();
    if (simulationService.currentSimulation != null) {
      _nameController.text = simulationService.currentSimulation!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    final simulationService = context.read<SimulationService>();
    simulationService.setStep(step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    final simulationService = context.read<SimulationService>();
    if (simulationService.currentStep < 3) {
      _onStepChanged(simulationService.currentStep + 1);
    } else {
      _runSimulation();
    }
  }

  void _onBack() {
    final simulationService = context.read<SimulationService>();
    if (simulationService.currentStep > 0) {
      _onStepChanged(simulationService.currentStep - 1);
    } else {
      context.pop();
    }
  }

  Future<void> _runSimulation() async {
    final authService = context.read<AuthService>();
    final simulationService = context.read<SimulationService>();
    final notificationService = context.read<NotificationService>();

    if (authService.user == null) return;

    final name = _nameController.text.isEmpty
        ? 'Simulation ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
        : _nameController.text;

    notificationService.notifySimulationStarted(name);

    // Run local simulation for instant results
    final result = await simulationService.runSimulation(
      userId: authService.user!.id,
      name: name,
    );

    if (result != null && mounted) {
      notificationService.notifySimulationCompleted(
        name,
        resultStatus: result.status.name,
      );
      
      // Also save to backend (non-blocking)
      simulationService.createSimulationOnBackend(
        name: name,
        description: 'Created from mobile app',
        params: simulationService.currentParams,
        isPublic: false,
      ).then((_) {
        debugPrint('Simulation saved to backend');
      }).catchError((e) {
        debugPrint('Failed to save to backend: $e');
      });
      
      context.go('/results/${simulationService.currentSimulation!.id}');
    } else if (mounted) {
      notificationService.notifySimulationFailed(
        name,
        simulationService.error ?? 'Unknown error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final simulationService = context.watch<SimulationService>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'New Simulation',
        onBack: _onBack,
        actions: [
          TextButton(
            onPressed: () {
              simulationService.resetWizard();
              context.pop();
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: simulationService.isRunning,
        message: 'Analyzing structure...\n${(simulationService.progress * 100).toInt()}%',
        child: Column(
          children: [
            // Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: StepIndicator(
                currentStep: simulationService.currentStep,
                steps: const ['Structure', 'Dimensions', 'Material', 'Review'],
                onStepTap: _onStepChanged,
              ),
            ).animate().fadeIn().slideY(begin: -0.2),

            // Simulation Name Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomTextField(
                hint: 'Enter simulation name',
                controller: _nameController,
                prefixIcon: Icons.label_outline,
              ),
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 16),

            // Step Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StructureStep(
                    params: simulationService.currentParams,
                    onChanged: simulationService.updateParams,
                  ),
                  DimensionsStep(
                    params: simulationService.currentParams,
                    onChanged: simulationService.updateParams,
                  ),
                  MaterialStep(
                    params: simulationService.currentParams,
                    onChanged: simulationService.updateParams,
                  ),
                  ReviewStep(
                    params: simulationService.currentParams,
                    name: _nameController.text,
                  ),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (simulationService.currentStep > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          onPressed: _onBack,
                          type: ButtonType.outline,
                          icon: Icons.arrow_back_rounded,
                        ),
                      ),
                    if (simulationService.currentStep > 0)
                      const SizedBox(width: 16),
                    Expanded(
                      flex: simulationService.currentStep == 0 ? 1 : 1,
                      child: CustomButton(
                        text: simulationService.currentStep == 3
                            ? 'Run Analysis'
                            : 'Continue',
                        onPressed: _onNext,
                        icon: simulationService.currentStep == 3
                            ? Icons.play_arrow_rounded
                            : Icons.arrow_forward_rounded,
                        iconRight: true,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
