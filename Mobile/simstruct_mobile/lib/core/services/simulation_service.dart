import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/simulation.dart';
import '../models/simulation_params.dart';
import 'api_service.dart';

/// Simulation Service - Manages simulation operations with REAL BACKEND
class SimulationService extends ChangeNotifier {
  // API Service for backend calls
  final ApiService _apiService = ApiService();
  
  final List<Simulation> _simulations = [];
  List<Simulation> _favoriteSimulations = [];
  List<Simulation> _publicSimulations = [];
  Simulation? _currentSimulation;
  SimulationParams _currentParams = const SimulationParams();
  int _currentStep = 0;
  bool _isRunning = false;
  bool _isLoading = false;
  double _progress = 0.0;
  String? _error;
  String? _currentUserId;

  // Getters
  List<Simulation> get simulations => List.unmodifiable(_simulations);
  List<Simulation> get favoriteSimulationsFromBackend => _favoriteSimulations;
  List<Simulation> get publicSimulations => _publicSimulations;
  Simulation? get currentSimulation => _currentSimulation;
  SimulationParams get currentParams => _currentParams;
  int get currentStep => _currentStep;
  bool get isRunning => _isRunning;
  bool get isLoading => _isLoading;
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

  /// Load simulations from REAL BACKEND
  Future<void> loadSimulations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('Loading simulations from backend...');
      final response = await _apiService.get(ApiConfig.simulations);
      
      debugPrint('Response success: ${response.success}');
      debugPrint('Response statusCode: ${response.statusCode}');
      debugPrint('Response data type: ${response.data?.runtimeType}');
      debugPrint('Response data: ${response.data}');
      
      _simulations.clear();
      
      if (response.success) {
        if (response.data == null) {
          debugPrint('⚠️ Success but data is null');
          _isLoading = false;
          notifyListeners();
          return;
        }
        
        // Handle different response formats
        List<dynamic> simulationsList = [];
        
        if (response.data is List) {
          // Direct array response
          simulationsList = response.data as List<dynamic>;
          debugPrint('✓ Direct array format: ${simulationsList.length} items');
        } else if (response.data is Map) {
          // Wrapped response with 'data' field
          final map = response.data as Map<String, dynamic>;
          if (map.containsKey('data')) {
            if (map['data'] is List) {
              simulationsList = map['data'] as List<dynamic>;
              debugPrint('✓ Wrapped format: ${simulationsList.length} items');
            } else {
              debugPrint('⚠️ data field is not a list: ${map['data']?.runtimeType}');
            }
          } else {
            debugPrint('⚠️ Map response but no data field. Keys: ${map.keys}');
          }
        } else {
          debugPrint('⚠️ Unknown response format: ${response.data.runtimeType}');
        }
        
        if (simulationsList.isNotEmpty) {
          _simulations.addAll(
            simulationsList.map((json) => _parseSimulationFromBackend(json)).toList()
          );
          debugPrint('✅ Loaded ${_simulations.length} simulations from backend');
        } else {
          debugPrint('ℹ️ No simulations found in response');
        }
      } else {
        debugPrint('❌ Failed to load simulations: ${response.message}');
        _error = response.message ?? 'Failed to load simulations';
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading simulations: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = 'Failed to load simulations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load favorite simulations from backend
  Future<void> loadFavoriteSimulations() async {
    try {
      debugPrint('Loading favorite simulations...');
      final response = await _apiService.get('${ApiConfig.simulations}/favorites');
      
      if (response.success && response.data != null) {
        List<dynamic> simulationsList = [];
        
        if (response.data is List) {
          simulationsList = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final map = response.data as Map<String, dynamic>;
          if (map.containsKey('data') && map['data'] is List) {
            simulationsList = map['data'] as List<dynamic>;
          }
        }
        
        _favoriteSimulations = simulationsList.map((json) => _parseSimulationFromBackend(json)).toList();
        debugPrint('✅ Loaded ${_favoriteSimulations.length} favorite simulations');
        notifyListeners();
      } else {
        debugPrint('⚠️ Failed to load favorites: ${response.message}');
      }
    } catch (e) {
      debugPrint('❌ Error loading favorites: $e');
    }
  }

  /// Load public simulations (community)
  Future<void> loadPublicSimulations() async {
    try {
      debugPrint('Loading public simulations...');
      final response = await _apiService.get('${ApiConfig.simulations}/public');
      
      if (response.success && response.data != null) {
        List<dynamic> simulationsList = [];
        
        if (response.data is List) {
          simulationsList = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final map = response.data as Map<String, dynamic>;
          if (map.containsKey('data') && map['data'] is List) {
            simulationsList = map['data'] as List<dynamic>;
          }
        }
        
        _publicSimulations = simulationsList.map((json) => _parseSimulationFromBackend(json)).toList();
        debugPrint('✅ Loaded ${_publicSimulations.length} public simulations');
        notifyListeners();
      } else {
        debugPrint('⚠️ Failed to load public simulations: ${response.message}');
      }
    } catch (e) {
      debugPrint('❌ Error loading public simulations: $e');
    }
  }

  /// Create a new simulation - CALLS REAL BACKEND (WITH AI SUPPORT)
  /// All parameters including AI params sent from mobile to backend
  Future<Simulation?> createSimulationOnBackend({
    required String name,
    String? description,
    required SimulationParams params,
    bool isPublic = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Build request body matching backend SimulationRequest
      // Includes all AI parameters for backend AI predictions
      final body = {
        'name': name,
        'description': description ?? 'Created from mobile app',
        'beamLength': params.length,
        'beamWidth': params.width,
        'beamHeight': params.height,
        'materialType': _mapMaterialType(params.material),
        'elasticModulus': params.elasticModulus,
        'density': params.density,
        'yieldStrength': params.yieldStrength,
        'loadType': _mapLoadType(params.loadType),
        'loadMagnitude': params.loadValue,
        'loadPosition': params.loadPosition,
        'supportType': _mapSupportType(params.supportType),
        'isPublic': isPublic,
        'numFloors': params.numFloors,
        'floorHeight': params.floorHeight,
        'numBeams': params.numBeams,
        'numColumns': params.numColumns,
        'beamSection': params.beamSection,
        'columnSection': params.columnSection,
        'concreteStrength': params.concreteStrength,
        'steelGrade': params.steelGrade,
        'windLoad': params.windLoad,
        'liveLoad': params.liveLoad,
        'deadLoad': params.deadLoad,
      };

      debugPrint('📤 Creating simulation on backend');
      debugPrint('📋 Request body: $body');

      final response = await _apiService.post(
        ApiConfig.simulations,
        body: body,
      );

      debugPrint('📥 Backend response - Success: ${response.success}, Status: ${response.statusCode}');
      if (!response.success) {
        debugPrint('❌ Error message: ${response.message}');
        debugPrint('❌ Error data: ${response.data}');
      }

      if (response.success && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final simulation = _parseSimulationFromBackend(data);
        
        // Add to local list
        _simulations.insert(0, simulation);
        _currentSimulation = simulation;
        
        debugPrint('✅ Simulation created: ${simulation.id}');
        _isLoading = false;
        notifyListeners();
        return simulation;
      } else {
        final errorMsg = response.message ?? 'Unknown error';
        debugPrint('❌ Failed to create simulation: $errorMsg');
        _error = errorMsg;
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception creating simulation: $e');
      _error = 'Failed to create simulation: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Create a new simulation (local, for wizard)
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
    _currentStep = step.clamp(0, 4);
    notifyListeners();
  }

  /// Go to next step
  void nextStep() {
    if (_currentStep < 4) {
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
    debugPrint('🔄 Wizard reset with default params:');
    debugPrint('  - numFloors: ${_currentParams.numFloors}');
    debugPrint('  - floorHeight: ${_currentParams.floorHeight}');
    debugPrint('  - numBeams: ${_currentParams.numBeams}');
    debugPrint('  - numColumns: ${_currentParams.numColumns}');
    debugPrint('  - beamSection: ${_currentParams.beamSection}');
    debugPrint('  - columnSection: ${_currentParams.columnSection}');
    notifyListeners();
  }

  /// Run simulation analysis - CALLS REAL BACKEND + AI
  /// All parameters including AI params sent from mobile to backend
  Future<Simulation?> runSimulationOnBackend({
    required String userId,
    required String name,
    String? description,
  }) async {
    _isRunning = true;
    _progress = 0.0;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🚀 Running simulation on backend with AI...');
      
      // Update status to running
      if (_currentSimulation != null) {
        _updateSimulationStatus(SimulationStatus.running);
      }

      // Call backend to create and process simulation
      // AI parameters auto-generated from beam params
      final simulation = await createSimulationOnBackend(
        name: name,
        description: description ?? 'Created from mobile app',
        params: _currentParams,
        isPublic: false,
      );

      if (simulation != null) {
        _currentSimulation = simulation;
        _isRunning = false;
        _progress = 1.0;
        notifyListeners();
        debugPrint('✅ Simulation completed: ${simulation.id}');
        return simulation;
      } else {
        throw Exception('Backend returned null simulation');
      }
    } catch (e) {
      debugPrint('❌ Error running simulation: $e');
      _error = e.toString();
      if (_currentSimulation != null) {
        _updateSimulationStatus(SimulationStatus.failed);
      }
      _isRunning = false;
      notifyListeners();
      return null;
    }
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

  /// Toggle favorite status - CALLS REAL BACKEND
  Future<bool> toggleFavoriteOnBackend(String simulationId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.simulations}/$simulationId/favorite',
      );

      if (response.success && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final simulation = _parseSimulationFromBackend(data);
        
        // Update in local list
        final index = _simulations.indexWhere((s) => s.id == simulationId);
        if (index != -1) {
          _simulations[index] = simulation;
        }
        
        // Refresh favorites list
        await loadFavoriteSimulations();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  /// Toggle favorite status (local)
  void toggleFavorite(String simulationId) {
    // Also call backend
    toggleFavoriteOnBackend(simulationId);
    
    // Local update for instant feedback
    final index = _simulations.indexWhere((s) => s.id == simulationId);
    if (index != -1) {
      _simulations[index] = _simulations[index].copyWith(
        isFavorite: !_simulations[index].isFavorite,
      );
      notifyListeners();
    }
  }

  /// Delete simulation - CALLS REAL BACKEND
  Future<bool> deleteSimulation(String simulationId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.simulations}/$simulationId',
      );

      if (response.success) {
        // Remove from local lists
        _simulations.removeWhere((s) => s.id == simulationId);
        _favoriteSimulations.removeWhere((s) => s.id == simulationId);
        _publicSimulations.removeWhere((s) => s.id == simulationId);
        
        if (_currentSimulation?.id == simulationId) {
          _currentSimulation = null;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting simulation: $e');
      return false;
    }
  }

  /// Toggle public status - CALLS REAL BACKEND
  Future<bool> togglePublicOnBackend(String simulationId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.simulations}/$simulationId/public',
      );

      if (response.success && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final simulation = _parseSimulationFromBackend(data);
        
        // Update in local list
        final index = _simulations.indexWhere((s) => s.id == simulationId);
        if (index != -1) {
          _simulations[index] = simulation;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling public: $e');
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

  /// Get simulation from backend by ID
  Future<Simulation?> getSimulationFromBackend(String id) async {
    try {
      debugPrint('📥 Fetching simulation from backend: $id');
      final response = await _apiService.get('${ApiConfig.simulations}/$id');
      
      debugPrint('📦 Response status: ${response.success}, statusCode: ${response.statusCode}');
      debugPrint('📦 Response data type: ${response.data?.runtimeType}');
      
      if (response.success && response.data != null) {
        final data = response.data['data'] ?? response.data;
        debugPrint('📦 Simulation data: $data');
        debugPrint('📦 Results field: ${data['results']}');
        
        final simulation = _parseSimulationFromBackend(data);
        
        debugPrint('✅ Parsed simulation: ${simulation.name}');
        debugPrint('✅ Result: ${simulation.result != null ? "Available" : "NULL"}');
        if (simulation.result != null) {
          debugPrint('   - maxStress: ${simulation.result!.maxStress}');
          debugPrint('   - maxDeflection: ${simulation.result!.maxDeflection}');
          debugPrint('   - maxBendingMoment: ${simulation.result!.maxBendingMoment}');
          debugPrint('   - maxShearForce: ${simulation.result!.maxShearForce}');
          debugPrint('   - safetyFactor: ${simulation.result!.safetyFactor}');
          debugPrint('   - weight: ${simulation.result!.weight}');
        }
        
        // Add to local list if not exists
        final existingIndex = _simulations.indexWhere((s) => s.id == id);
        if (existingIndex == -1) {
          _simulations.add(simulation);
        } else {
          _simulations[existingIndex] = simulation;
        }
        
        notifyListeners();
        return simulation;
      }
      
      debugPrint('❌ Failed to fetch simulation');
      return null;
    } catch (e) {
      debugPrint('❌ Error loading simulation from backend: $e');
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

  // ========== HELPER: PARSE SIMULATION FROM BACKEND ==========
  /// Parse backend response to Simulation model
  Simulation _parseSimulationFromBackend(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing simulation from backend...');
    
    // Parse results if present
    AnalysisResult? result;
    if (json['results'] != null) {
      final r = json['results'];
      debugPrint('📊 Results data found: $r');
      
      // Parse AI predictions if present
      double? stabilityIndex;
      double? seismicResistance;
      double? crackRisk;
      double? foundationStability;
      
      if (r['aiPredictions'] != null) {
        final ai = r['aiPredictions'];
        stabilityIndex = (ai['stabilityIndex'] as num?)?.toDouble();
        seismicResistance = (ai['seismicResistance'] as num?)?.toDouble();
        crackRisk = (ai['crackRisk'] as num?)?.toDouble();
        foundationStability = (ai['foundationStability'] as num?)?.toDouble();
      }
      
      debugPrint('   Raw maxStress: ${r['maxStress']} (type: ${r['maxStress']?.runtimeType})');
      debugPrint('   Raw maxDeflection: ${r['maxDeflection']} (type: ${r['maxDeflection']?.runtimeType})');
      debugPrint('   Raw maxBendingMoment: ${r['maxBendingMoment']} (type: ${r['maxBendingMoment']?.runtimeType})');
      debugPrint('   Raw maxShearForce: ${r['maxShearForce']} (type: ${r['maxShearForce']?.runtimeType})');
      debugPrint('   Raw safetyFactor: ${r['safetyFactor']} (type: ${r['safetyFactor']?.runtimeType})');
      debugPrint('   Raw weight: ${r['weight']} (type: ${r['weight']?.runtimeType})');
      
      result = AnalysisResult(
        safetyFactor: (r['safetyFactor'] as num?)?.toDouble() ?? 0.0,
        maxDeflection: (r['maxDeflection'] as num?)?.toDouble() ?? 0.0,
        maxStress: (r['maxStress'] as num?)?.toDouble() ?? 0.0,
        bucklingLoad: (r['criticalLoad'] as num?)?.toDouble() ?? 0.0,
        naturalFrequency: (r['naturalFrequency'] as num?)?.toDouble() ?? 0.0,
        status: (r['isSafe'] == true) ? ResultStatus.safe : ResultStatus.warning,
        recommendations: r['recommendations'] != null 
            ? [r['recommendations'].toString()] 
            : [],
        maxBendingMoment: (r['maxBendingMoment'] as num?)?.toDouble(),
        maxShearForce: (r['maxShearForce'] as num?)?.toDouble(),
        weight: (r['weight'] as num?)?.toDouble(),
        stabilityIndex: stabilityIndex,
        seismicResistance: seismicResistance,
        crackRisk: crackRisk,
        foundationStability: foundationStability,
      );
    }

    // Parse status
    SimulationStatus status = SimulationStatus.draft;
    final statusStr = json['status']?.toString().toUpperCase();
    if (statusStr == 'COMPLETED') {
      status = SimulationStatus.completed;
    } else if (statusStr == 'RUNNING') {
      status = SimulationStatus.running;
    } else if (statusStr == 'FAILED') {
      status = SimulationStatus.failed;
    } else if (statusStr == 'PENDING') {
      status = SimulationStatus.draft;
    }

    // Parse material type
    StructuralMaterial material = StructuralMaterial.steel;
    final materialStr = json['materialType']?.toString().toUpperCase();
    if (materialStr == 'CONCRETE') {
      material = StructuralMaterial.concrete;
    } else if (materialStr == 'ALUMINUM') {
      material = StructuralMaterial.aluminum;
    } else if (materialStr == 'WOOD') {
      material = StructuralMaterial.wood;
    }

    // Parse load type
    LoadType loadType = LoadType.point;
    final loadTypeStr = json['loadType']?.toString().toUpperCase();
    if (loadTypeStr == 'DISTRIBUTED' || loadTypeStr == 'UNIFORM') {
      loadType = LoadType.distributed;
    } else if (loadTypeStr == 'MOMENT') {
      loadType = LoadType.moment;
    }

    // Parse support type
    SupportType supportType = SupportType.simplySupported;
    final supportStr = json['supportType']?.toString().toUpperCase();
    if (supportStr == 'FIXED_FIXED') {
      supportType = SupportType.fixedFixed;
    } else if (supportStr == 'FIXED_FREE' || supportStr == 'CANTILEVER') {
      supportType = SupportType.cantilever;
    } else if (supportStr == 'FIXED_PINNED' || supportStr == 'PINNED') {
      supportType = SupportType.pinned;
    } else if (supportStr == 'FIXED') {
      supportType = SupportType.fixed;
    }

    // Build params
    final params = SimulationParams(
      structureType: StructureType.beam,
      material: material,
      length: (json['beamLength'] as num?)?.toDouble() ?? 5.0,
      width: (json['beamWidth'] as num?)?.toDouble() ?? 0.3,
      height: (json['beamHeight'] as num?)?.toDouble() ?? 0.5,
      loadType: loadType,
      loadValue: (json['loadMagnitude'] as num?)?.toDouble() ?? 10.0,
      loadPosition: (json['loadPosition'] as num?)?.toDouble() ?? 0.5,
      supportType: supportType,
      elasticModulus: (json['elasticModulus'] as num?)?.toDouble() ?? material.elasticModulus,
      density: (json['density'] as num?)?.toDouble() ?? material.density,
      yieldStrength: (json['yieldStrength'] as num?)?.toDouble() ?? material.yieldStrength,
    );

    return Simulation(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled',
      description: json['description'],
      userId: json['userId'] ?? '',
      params: params,
      status: status,
      result: result,
      isFavorite: json['isFavorite'] ?? false,
      isShared: json['isPublic'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  // ========== HELPER: MAP MATERIAL TYPE ==========
  String _mapMaterialType(StructuralMaterial material) {
    switch (material) {
      case StructuralMaterial.steel:
        return 'STEEL';
      case StructuralMaterial.concrete:
        return 'CONCRETE';
      case StructuralMaterial.aluminum:
        return 'ALUMINUM';
      case StructuralMaterial.wood:
        return 'WOOD';
    }
  }

  // ========== HELPER: MAP LOAD TYPE ==========
  String _mapLoadType(LoadType loadType) {
    switch (loadType) {
      case LoadType.point:
        return 'POINT';
      case LoadType.distributed:
        return 'DISTRIBUTED';
      case LoadType.moment:
        return 'MOMENT';
    }
  }

  // ========== HELPER: MAP SUPPORT TYPE ==========
  String _mapSupportType(SupportType supportType) {
    switch (supportType) {
      case SupportType.simplySupported:
        return 'SIMPLY_SUPPORTED';
      case SupportType.fixedFixed:
        return 'FIXED_FIXED';
      case SupportType.cantilever:
        return 'FIXED_FREE';
      case SupportType.pinned:
        return 'PINNED';
      case SupportType.fixed:
        return 'FIXED';
      case SupportType.roller:
        return 'SIMPLY_SUPPORTED'; // Fallback
    }
  }

  // ========== CLEAR DATA ==========
  /// Clear all data (on logout)
  void clearData() {
    _simulations.clear();
    _favoriteSimulations.clear();
    _publicSimulations.clear();
    _currentSimulation = null;
    _error = null;
    notifyListeners();
  }
}
