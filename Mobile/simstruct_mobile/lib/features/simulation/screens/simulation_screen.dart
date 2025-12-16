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
import '../widgets/ai_parameters_step.dart';
import '../widgets/review_step.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _nameController = TextEditingController();
  final _pageController = PageController();
  
  // AI Parameters controllers (optional)
  final _numFloorsController = TextEditingController();
  final _floorHeightController = TextEditingController();
  final _numBeamsController = TextEditingController();
  final _numColumnsController = TextEditingController();
  final _beamSectionController = TextEditingController();
  final _columnSectionController = TextEditingController();
  final _concreteStrengthController = TextEditingController();
  final _steelGradeController = TextEditingController();
  final _windLoadController = TextEditingController();
  final _liveLoadController = TextEditingController();
  final _deadLoadController = TextEditingController();

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
    _numFloorsController.dispose();
    _floorHeightController.dispose();
    _numBeamsController.dispose();
    _numColumnsController.dispose();
    _beamSectionController.dispose();
    _columnSectionController.dispose();
    _concreteStrengthController.dispose();
    _steelGradeController.dispose();
    _windLoadController.dispose();
    _liveLoadController.dispose();
    _deadLoadController.dispose();
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
    if (simulationService.currentStep < 4) {
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

    // Parse AI parameters (if provided)
    int? numFloors = _numFloorsController.text.isEmpty 
        ? null 
        : int.tryParse(_numFloorsController.text);
    double? floorHeight = _floorHeightController.text.isEmpty
        ? null
        : double.tryParse(_floorHeightController.text);
    int? numBeams = _numBeamsController.text.isEmpty
        ? null
        : int.tryParse(_numBeamsController.text);
    int? numColumns = _numColumnsController.text.isEmpty
        ? null
        : int.tryParse(_numColumnsController.text);
    double? beamSection = _beamSectionController.text.isEmpty
        ? null
        : double.tryParse(_beamSectionController.text);
    double? columnSection = _columnSectionController.text.isEmpty
        ? null
        : double.tryParse(_columnSectionController.text);
    double? concreteStrength = _concreteStrengthController.text.isEmpty
        ? null
        : double.tryParse(_concreteStrengthController.text);
    double? steelGrade = _steelGradeController.text.isEmpty
        ? null
        : double.tryParse(_steelGradeController.text);
    double? windLoad = _windLoadController.text.isEmpty
        ? null
        : double.tryParse(_windLoadController.text);
    double? liveLoad = _liveLoadController.text.isEmpty
        ? null
        : double.tryParse(_liveLoadController.text);
    double? deadLoad = _deadLoadController.text.isEmpty
        ? null
        : double.tryParse(_deadLoadController.text);

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    'Processing Simulation',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI model is analyzing your structure...\nThis may take a few seconds',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Call REAL backend + AI model with parameters
    final simulation = await simulationService.runSimulationOnBackend(
      userId: authService.user!.id,
      name: name,
      description: 'Created from mobile app',
      numFloors: numFloors,
      floorHeight: floorHeight,
      numBeams: numBeams,
      numColumns: numColumns,
      beamSection: beamSection,
      columnSection: columnSection,
      concreteStrength: concreteStrength,
      steelGrade: steelGrade,
      windLoad: windLoad,
      liveLoad: liveLoad,
      deadLoad: deadLoad,
    );

    // Close loading dialog
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (simulation != null && mounted) {
      notificationService.notifySimulationCompleted(
        name,
        resultStatus: simulation.status.name,
      );
      
      // Reload simulations to update lists
      await simulationService.loadSimulations(authService.user!.id);
      
      // Wait a bit for data to settle
      await Future.delayed(const Duration(milliseconds: 500));
      
      context.go('/results/${simulation.id}');
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
                steps: const ['Structure', 'Dimensions', 'Material', 'AI Params', 'Review'],
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
                  AIParametersStep(
                    numFloorsController: _numFloorsController,
                    floorHeightController: _floorHeightController,
                    numBeamsController: _numBeamsController,
                    numColumnsController: _numColumnsController,
                    beamSectionController: _beamSectionController,
                    columnSectionController: _columnSectionController,
                    concreteStrengthController: _concreteStrengthController,
                    steelGradeController: _steelGradeController,
                    windLoadController: _windLoadController,
                    liveLoadController: _liveLoadController,
                    deadLoadController: _deadLoadController,
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
                        text: simulationService.currentStep == 4
                            ? 'Run Analysis'
                            : 'Continue',
                        onPressed: _onNext,
                        icon: simulationService.currentStep == 4
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
