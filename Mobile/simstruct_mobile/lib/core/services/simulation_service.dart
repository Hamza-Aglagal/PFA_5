import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/simulation.dart';
import '../models/simulation_params.dart';

/// Simulation Service - Manages simulation operations
class SimulationService extends ChangeNotifier {
  final List<Simulation> _simulations = [];
  Simulation? _currentSimulation;
  SimulationParams _currentParams = const SimulationParams();
  int _currentStep = 0;
  bool _isRunning = false;
  double _progress = 0.0;
  String? _error;
  String? _currentUserId;

  // Getters
  List<Simulation> get simulations => List.unmodifiable(_simulations);
  Simulation? get currentSimulation => _currentSimulation;
  SimulationParams get currentParams => _currentParams;
  int get currentStep => _currentStep;
  bool get isRunning => _isRunning;
  double get progress => _progress;
  String? get error => _error;

  // Computed getters
  List<Simulation> get recentSimulations {
    final sorted = List<Simulation>.from(_simulations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  List<Simulation> get completedSimulations =>
      _simulations.where((s) => s.status == SimulationStatus.completed).toList();

  List<Simulation> get favoriteSimulations =>
      _simulations.where((s) => s.isFavorite).toList();

  int get totalSimulations => _simulations.length;
  int get completedCount => completedSimulations.length;

  /// Initialize with mock data
  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await loadSimulations(userId);
  }

  /// Load simulations from server
  Future<void> loadSimulations(String userId) async {
    try {
      // Mock loading - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));

      _simulations.clear();
      _simulations.addAll(_generateMockSimulations(userId));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load simulations';
      notifyListeners();
    }
  }

  /// Create a new simulation
  Simulation createSimulation({
    required String userId,
    String? name,
    SimulationParams? params,
  }) {
    final simulation = Simulation.create(
      userId: userId,
      name: name,
      params: params ?? _currentParams,
    );
    _simulations.insert(0, simulation);
    _currentSimulation = simulation;
    notifyListeners();
    return simulation;
  }

  /// Update simulation parameters
  void updateParams(SimulationParams params) {
    _currentParams = params;
    if (_currentSimulation != null) {
      _currentSimulation = _currentSimulation!.copyWith(
        params: params,
        updatedAt: DateTime.now(),
      );
      final index = _simulations.indexWhere((s) => s.id == _currentSimulation!.id);
      if (index != -1) {
        _simulations[index] = _currentSimulation!;
      }
    }
    notifyListeners();
  }

  /// Set current step
  void setStep(int step) {
    _currentStep = step.clamp(0, 3);
    notifyListeners();
  }

  /// Go to next step
  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Reset wizard
  void resetWizard() {
    _currentStep = 0;
    _currentParams = const SimulationParams();
    _currentSimulation = null;
    notifyListeners();
  }

  /// Run simulation analysis
  Future<AnalysisResult?> runSimulation({
    required String userId,
    String? name,
  }) async {
    _isRunning = true;
    _progress = 0.0;
    _error = null;
    notifyListeners();

    try {
      // Create simulation if not exists
      if (_currentSimulation == null) {
        createSimulation(userId: userId, name: name);
      }

      // Update status to running
      _updateSimulationStatus(SimulationStatus.running);

      // Simulate analysis progress
      for (var i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        _progress = i / 100;
        notifyListeners();
      }

      // Generate results
      final result = _calculateResults(_currentParams);

      // Update simulation with results
      _currentSimulation = _currentSimulation!.copyWith(
        status: SimulationStatus.completed,
        result: result,
        updatedAt: DateTime.now(),
      );

      final index = _simulations.indexWhere((s) => s.id == _currentSimulation!.id);
      if (index != -1) {
        _simulations[index] = _currentSimulation!;
      }

      _isRunning = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _updateSimulationStatus(SimulationStatus.failed);
      _isRunning = false;
      notifyListeners();
      return null;
    }
  }

  /// Calculate simulation results
  AnalysisResult _calculateResults(SimulationParams params) {
    final random = Random();
    
    // Simplified structural analysis calculations
    final momentOfInertia = (params.width * pow(params.height, 3)) / 12;
    final crossSectionArea = params.width * params.height;
    
    // Max deflection calculation (simplified)
    final maxDeflection = (params.loadMagnitude * pow(params.length, 3)) / 
        (48 * params.elasticModulus * 1e9 * momentOfInertia) * 1000; // in mm
    
    // Max stress calculation
    final maxStress = (params.loadMagnitude * params.length * params.height / 2) / 
        (4 * momentOfInertia) / 1e6; // in MPa
    
    // Safety factor
    final safetyFactor = params.yieldStrength / maxStress;
    
    // Buckling load (simplified Euler's formula)
    final bucklingLoad = (pow(pi, 2) * params.elasticModulus * 1e9 * momentOfInertia) / 
        pow(params.length, 2) / 1000; // in kN
    
    // Natural frequency (simplified)
    final naturalFrequency = (pi / 2) * sqrt((params.elasticModulus * 1e9 * momentOfInertia) / 
        (params.density * crossSectionArea * pow(params.length, 4))) / (2 * pi);

    // Determine status
    final status = AnalysisResult.calculateStatus(safetyFactor);

    // Generate stress distribution
    final stressDistribution = List.generate(20, (i) {
      final pos = i / 19.0 * params.length;
      final stress = maxStress * sin(pi * pos / params.length);
      return StressPoint(
        position: pos,
        stress: stress,
        normalizedStress: stress / maxStress,
      );
    });

    // Generate deflection curve
    final deflectionCurve = List.generate(20, (i) {
      final pos = i / 19.0 * params.length;
      final x = pos / params.length;
      final deflection = maxDeflection * 16 * pow(x, 2) * pow(1 - x, 2);
      return DeflectionPoint(
        position: pos,
        deflection: deflection,
      );
    });

    // Generate recommendations
    final recommendations = <String>[];
    if (safetyFactor < 2.0) {
      recommendations.add('Consider increasing cross-section dimensions for better safety margin');
    }
    if (safetyFactor < 1.5) {
      recommendations.add('Structure is at risk - immediate redesign recommended');
      recommendations.add('Use a stronger material or reduce applied load');
    }
    if (maxDeflection > params.length / 250) {
      recommendations.add('Deflection exceeds L/250 serviceability limit - consider stiffening');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Structure meets all safety and serviceability requirements');
      recommendations.add('Design is optimized for the given loading conditions');
    }

    // AI Insight
    final aiInsight = AIInsight(
      summary: safetyFactor >= 2.0
          ? 'The structure demonstrates excellent stability under the specified loading conditions.'
          : safetyFactor >= 1.5
              ? 'The structure is stable but operating near safety margins. Consider optimization.'
              : 'Critical: The structure requires immediate attention to prevent failure.',
      keyFindings: [
        'Maximum stress occurs at ${(params.loadPosition / 100 * params.length).toStringAsFixed(2)}m from support',
        'Peak deflection is ${maxDeflection.toStringAsFixed(2)}mm at mid-span',
        '${params.material.displayName} provides ${safetyFactor >= 2.0 ? "adequate" : "marginal"} strength margin',
      ],
      improvements: recommendations,
      confidenceScore: 0.85 + random.nextDouble() * 0.1,
      generatedAt: DateTime.now(),
    );

    return AnalysisResult(
      safetyFactor: safetyFactor,
      maxDeflection: maxDeflection,
      maxStress: maxStress,
      bucklingLoad: bucklingLoad,
      naturalFrequency: naturalFrequency,
      status: status,
      recommendations: recommendations,
      stressDistribution: stressDistribution,
      deflectionCurve: deflectionCurve,
      aiInsight: aiInsight,
    );
  }

  /// Update simulation status
  void _updateSimulationStatus(SimulationStatus status) {
    if (_currentSimulation != null) {
      _currentSimulation = _currentSimulation!.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      final index = _simulations.indexWhere((s) => s.id == _currentSimulation!.id);
      if (index != -1) {
        _simulations[index] = _currentSimulation!;
      }
      notifyListeners();
    }
  }

  /// Toggle favorite status
  void toggleFavorite(String simulationId) {
    final index = _simulations.indexWhere((s) => s.id == simulationId);
    if (index != -1) {
      _simulations[index] = _simulations[index].copyWith(
        isFavorite: !_simulations[index].isFavorite,
      );
      notifyListeners();
    }
  }

  /// Delete simulation
  Future<bool> deleteSimulation(String simulationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _simulations.removeWhere((s) => s.id == simulationId);
      if (_currentSimulation?.id == simulationId) {
        _currentSimulation = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Duplicate simulation
  Simulation duplicateSimulation(Simulation simulation) {
    final newSimulation = Simulation.create(
      userId: simulation.userId,
      name: '${simulation.name} (Copy)',
      params: simulation.params,
    );
    _simulations.insert(0, newSimulation);
    notifyListeners();
    return newSimulation;
  }

  /// Clone shared simulation
  Future<Simulation?> cloneSharedSimulation(String simulationId) async {
    try {
      // In real app, fetch simulation from server
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock: create a new simulation based on ID
      final newSimulation = Simulation.create(
        userId: _currentUserId ?? 'user',
        name: 'Cloned Simulation',
        params: const SimulationParams(
          structureType: StructureType.beam,
          material: StructuralMaterial.steel,
          length: 10,
          width: 0.5,
          height: 0.8,
          loadMagnitude: 50,
        ),
      );
      _simulations.insert(0, newSimulation);
      notifyListeners();
      return newSimulation;
    } catch (e) {
      return null;
    }
  }

  /// Set a shared simulation as current for viewing
  /// This creates a mock simulation object from shared simulation data
  void setSharedSimulationForViewing({
    required String simulationId,
    required String name,
    required SimulationStatus status,
    ResultStatus? resultStatus,
    String? ownerName,
  }) {
    // Create a mock simulation from shared data
    _currentSimulation = Simulation(
      id: simulationId,
      name: name,
      description: ownerName != null ? 'Shared by $ownerName' : null,
      userId: 'shared',
      params: const SimulationParams(
        structureType: StructureType.beam,
        material: StructuralMaterial.steel,
        length: 10,
        width: 0.5,
        height: 0.8,
        loadMagnitude: 50,
      ),
      status: status,
      result: resultStatus != null
          ? AnalysisResult(
              safetyFactor: resultStatus == ResultStatus.safe
                  ? 2.5
                  : (resultStatus == ResultStatus.warning ? 1.3 : 0.8),
              maxDeflection: 15.0,
              maxStress: 120.0,
              bucklingLoad: 400,
              naturalFrequency: 10.0,
              status: resultStatus,
              recommendations: [
                if (resultStatus == ResultStatus.safe)
                  'Structure meets all safety requirements',
                if (resultStatus == ResultStatus.warning)
                  'Consider reinforcing critical sections',
                if (resultStatus == ResultStatus.critical)
                  'Immediate structural review required',
              ],
            )
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Search simulations
  List<Simulation> search(String query) {
    if (query.isEmpty) return _simulations;
    final lowerQuery = query.toLowerCase();
    return _simulations.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          s.params.structureType.displayName.toLowerCase().contains(lowerQuery) ||
          s.params.material.displayName.toLowerCase().contains(lowerQuery) ||
          (s.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter simulations
  List<Simulation> filter({
    StructureType? structureType,
    StructuralMaterial? material,
    SimulationStatus? status,
    ResultStatus? resultStatus,
  }) {
    return _simulations.where((s) {
      if (structureType != null && s.params.structureType != structureType) {
        return false;
      }
      if (material != null && s.params.material != material) {
        return false;
      }
      if (status != null && s.status != status) {
        return false;
      }
      if (resultStatus != null && s.result?.status != resultStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Load specific simulation
  void loadSimulation(String simulationId) {
    final simulation = _simulations.firstWhere(
      (s) => s.id == simulationId,
      orElse: () => throw Exception('Simulation not found'),
    );
    _currentSimulation = simulation;
    _currentParams = simulation.params;
    notifyListeners();
  }

  /// Get simulation by ID
  Simulation? getSimulationById(String id) {
    try {
      return _simulations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Generate mock simulations
  List<Simulation> _generateMockSimulations(String userId) {
    final now = DateTime.now();
    return [
      Simulation(
        id: 'sim_001',
        name: 'Bridge Load Analysis',
        description: 'Analysis of a pedestrian bridge structure',
        userId: userId,
        params: const SimulationParams(
          structureType: StructureType.beam,
          material: StructuralMaterial.steel,
          length: 15,
          width: 0.8,
          height: 1.2,
          loadMagnitude: 100,
        ),
        status: SimulationStatus.completed,
        result: AnalysisResult(
          safetyFactor: 2.8,
          maxDeflection: 12.5,
          maxStress: 89.3,
          bucklingLoad: 450,
          naturalFrequency: 12.5,
          status: ResultStatus.safe,
          recommendations: ['Structure meets all requirements'],
        ),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isFavorite: true,
      ),
      Simulation(
        id: 'sim_002',
        name: 'Building Frame Study',
        description: 'Portal frame for industrial building',
        userId: userId,
        params: const SimulationParams(
          structureType: StructureType.frame,
          material: StructuralMaterial.concrete,
          length: 8,
          width: 0.4,
          height: 0.6,
          loadMagnitude: 75,
        ),
        status: SimulationStatus.completed,
        result: AnalysisResult(
          safetyFactor: 1.6,
          maxDeflection: 8.2,
          maxStress: 18.7,
          bucklingLoad: 220,
          naturalFrequency: 8.2,
          status: ResultStatus.warning,
          recommendations: ['Consider increasing beam depth'],
        ),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Simulation(
        id: 'sim_003',
        name: 'Roof Truss Design',
        userId: userId,
        params: const SimulationParams(
          structureType: StructureType.truss,
          material: StructuralMaterial.aluminum,
          length: 12,
          width: 0.3,
          height: 0.3,
          loadMagnitude: 40,
        ),
        status: SimulationStatus.draft,
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
