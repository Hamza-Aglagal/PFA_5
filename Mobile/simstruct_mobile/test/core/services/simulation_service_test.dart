import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/simulation.dart';
import 'package:simstruct_mobile/core/models/simulation_params.dart';
import '../../helpers/mocks.dart';

void main() {
  group('MockSimulationService', () {
    late MockSimulationService simulationService;

    setUp(() {
      simulationService = MockSimulationService();
    });

    test('should start with empty simulations list', () {
      expect(simulationService.simulations, isEmpty);
    });

    test('should start with no current simulation', () {
      expect(simulationService.currentSimulation, isNull);
    });

    test('should start with default params', () {
      expect(simulationService.currentParams, isNotNull);
    });

    test('should start at step 0', () {
      expect(simulationService.currentStep, 0);
    });

    test('should start not running', () {
      expect(simulationService.isRunning, false);
    });

    test('should start not loading', () {
      expect(simulationService.isLoading, false);
    });

    test('should start with 0 progress', () {
      expect(simulationService.progress, 0.0);
    });

    test('should start with no error', () {
      expect(simulationService.error, isNull);
    });
  });

  group('MockSimulationService setters', () {
    late MockSimulationService simulationService;

    setUp(() {
      simulationService = MockSimulationService();
    });

    test('setSimulations should update simulations list', () {
      final simulations = MockData.createSimulations(count: 3);
      simulationService.setSimulations(simulations);

      expect(simulationService.simulations.length, 3);
    });

    test('setCurrentSimulation should update current simulation', () {
      final simulation = MockData.createSimulation();
      simulationService.setCurrentSimulation(simulation);

      expect(simulationService.currentSimulation, isNotNull);
      expect(simulationService.currentSimulation!.id, 'sim-1');
    });

    test('setCurrentParams should update current params', () {
      const params = SimulationParams(
        length: 10.0,
        width: 2.0,
        height: 1.5,
      );
      simulationService.setCurrentParams(params);

      expect(simulationService.currentParams.length, 10.0);
      expect(simulationService.currentParams.width, 2.0);
    });

    test('setCurrentStep should update current step', () {
      simulationService.setCurrentStep(3);
      expect(simulationService.currentStep, 3);
    });

    test('setIsRunning should update running state', () {
      simulationService.setIsRunning(true);
      expect(simulationService.isRunning, true);

      simulationService.setIsRunning(false);
      expect(simulationService.isRunning, false);
    });

    test('setIsLoading should update loading state', () {
      simulationService.setIsLoading(true);
      expect(simulationService.isLoading, true);

      simulationService.setIsLoading(false);
      expect(simulationService.isLoading, false);
    });

    test('setProgress should update progress', () {
      simulationService.setProgress(0.5);
      expect(simulationService.progress, 0.5);

      simulationService.setProgress(1.0);
      expect(simulationService.progress, 1.0);
    });

    test('setError should update error message', () {
      simulationService.setError('Test error');
      expect(simulationService.error, 'Test error');

      simulationService.setError(null);
      expect(simulationService.error, isNull);
    });
  });

  group('MockSimulationService computed getters', () {
    late MockSimulationService simulationService;

    setUp(() {
      simulationService = MockSimulationService();
    });

    test('recentSimulations should return last 5 simulations sorted by date', () {
      final simulations = MockData.createSimulations(count: 10);
      simulationService.setSimulations(simulations);

      final recent = simulationService.recentSimulations;
      expect(recent.length, 5);
    });

    test('completedSimulations should return only completed simulations', () {
      final simulations = [
        MockData.createSimulation(id: '1', status: SimulationStatus.completed),
        MockData.createSimulation(id: '2', status: SimulationStatus.running),
        MockData.createSimulation(id: '3', status: SimulationStatus.completed),
        MockData.createSimulation(id: '4', status: SimulationStatus.draft),
      ];
      simulationService.setSimulations(simulations);

      final completed = simulationService.completedSimulations;
      expect(completed.length, 2);
      expect(completed.every((s) => s.status == SimulationStatus.completed), true);
    });

    test('favoriteSimulations should return only favorite simulations', () {
      final simulations = [
        MockData.createSimulation(id: '1', isFavorite: true),
        MockData.createSimulation(id: '2', isFavorite: false),
        MockData.createSimulation(id: '3', isFavorite: true),
      ];
      simulationService.setSimulations(simulations);

      final favorites = simulationService.favoriteSimulations;
      expect(favorites.length, 2);
      expect(favorites.every((s) => s.isFavorite), true);
    });

    test('totalSimulations should return total count', () {
      final simulations = MockData.createSimulations(count: 7);
      simulationService.setSimulations(simulations);

      expect(simulationService.totalSimulations, 7);
    });

    test('completedCount should return count of completed simulations', () {
      final simulations = [
        MockData.createSimulation(id: '1', status: SimulationStatus.completed),
        MockData.createSimulation(id: '2', status: SimulationStatus.completed),
        MockData.createSimulation(id: '3', status: SimulationStatus.running),
      ];
      simulationService.setSimulations(simulations);

      expect(simulationService.completedCount, 2);
    });
  });

  group('MockSimulationService methods', () {
    late MockSimulationService simulationService;

    setUp(() {
      simulationService = MockSimulationService();
    });

    test('initialize should complete without error', () async {
      await expectLater(
        simulationService.initialize('user-1'),
        completes,
      );
    });

    test('loadSimulations should complete without error', () async {
      await expectLater(
        simulationService.loadSimulations('user-1'),
        completes,
      );
    });

    test('createSimulation should return a new simulation', () {
      final simulation = simulationService.createSimulation(
        userId: 'user-1',
        name: 'New Simulation',
      );

      expect(simulation, isNotNull);
      expect(simulation.userId, 'user-1');
      expect(simulation.name, 'New Simulation');
      expect(simulation.status, SimulationStatus.draft);
    });

    test('updateParams should update current params', () {
      const params = SimulationParams(
        length: 15.0,
        material: StructuralMaterial.concrete,
      );
      simulationService.updateParams(params);

      expect(simulationService.currentParams.length, 15.0);
      expect(simulationService.currentParams.material, StructuralMaterial.concrete);
    });

    test('setStep should update current step', () {
      simulationService.setStep(2);
      expect(simulationService.currentStep, 2);
    });

    test('nextStep should increment step', () {
      expect(simulationService.currentStep, 0);
      
      simulationService.nextStep();
      expect(simulationService.currentStep, 1);
      
      simulationService.nextStep();
      expect(simulationService.currentStep, 2);
    });

    test('previousStep should decrement step', () {
      simulationService.setStep(3);
      
      simulationService.previousStep();
      expect(simulationService.currentStep, 2);
      
      simulationService.previousStep();
      expect(simulationService.currentStep, 1);
    });

    test('previousStep should not go below 0', () {
      simulationService.setStep(0);
      simulationService.previousStep();
      
      expect(simulationService.currentStep, 0);
    });

    test('resetWizard should reset all wizard state', () {
      simulationService.setStep(3);
      simulationService.setCurrentSimulation(MockData.createSimulation());
      simulationService.setCurrentParams(const SimulationParams(length: 20.0));
      
      simulationService.resetWizard();

      expect(simulationService.currentStep, 0);
      expect(simulationService.currentSimulation, isNull);
    });

    test('selectSimulation should update current simulation', () {
      final simulation = MockData.createSimulation();
      simulationService.selectSimulation(simulation);

      expect(simulationService.currentSimulation, isNotNull);
      expect(simulationService.currentSimulation!.id, simulation.id);
    });

    test('clearCurrentSimulation should set current simulation to null', () {
      simulationService.setCurrentSimulation(MockData.createSimulation());
      simulationService.clearCurrentSimulation();

      expect(simulationService.currentSimulation, isNull);
    });

    test('deleteSimulation should return true', () async {
      final result = await simulationService.deleteSimulation('sim-1');
      expect(result, true);
    });

    test('toggleFavorite should return true', () async {
      final result = await simulationService.toggleFavorite('sim-1');
      expect(result, true);
    });

    test('runSimulation should complete without error', () async {
      await expectLater(
        simulationService.runSimulation('user-1'),
        completes,
      );
    });
  });

  group('MockSimulationService listener notifications', () {
    late MockSimulationService simulationService;

    setUp(() {
      simulationService = MockSimulationService();
    });

    test('should notify listeners on simulations change', () {
      var notificationCount = 0;
      simulationService.addListener(() {
        notificationCount++;
      });

      simulationService.setSimulations([]);
      expect(notificationCount, 1);

      final simulations = MockData.createSimulations(count: 2);
      simulationService.setSimulations(simulations);
      expect(notificationCount, 2);
    });

    test('should notify listeners on step change', () {
      var notificationCount = 0;
      simulationService.addListener(() {
        notificationCount++;
      });

      simulationService.nextStep();
      simulationService.nextStep();
      simulationService.previousStep();

      expect(notificationCount, 3);
    });

    test('should notify listeners on loading state change', () {
      var notificationCount = 0;
      simulationService.addListener(() {
        notificationCount++;
      });

      simulationService.setIsLoading(true);
      simulationService.setIsLoading(false);

      expect(notificationCount, 2);
    });
  });
}
