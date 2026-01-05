import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/simulation.dart';
import 'package:simstruct_mobile/core/models/simulation_params.dart';
import 'package:simstruct_mobile/core/models/user.dart';
import '../../../helpers/mocks.dart';

void main() {
  group('Dashboard Unit Tests', () {
    test('MockSimulationService should start with empty simulations', () {
      final service = MockSimulationService();
      expect(service.simulations, isEmpty);
      expect(service.isLoading, false);
    });

    test('MockSimulationService should add simulations', () {
      final service = MockSimulationService();
      final simulations = MockData.createSimulations(count: 5);
      service.setSimulations(simulations);
      
      expect(service.simulations.length, 5);
    });

    test('MockSimulationService should set current simulation', () {
      final service = MockSimulationService();
      final simulation = MockData.createSimulation(id: 'sim-1');
      service.setCurrentSimulation(simulation);
      
      expect(service.currentSimulation, simulation);
    });

    test('MockSimulationService should notify listeners on change', () {
      final service = MockSimulationService();
      var notified = false;
      service.addListener(() => notified = true);
      
      service.setSimulations([MockData.createSimulation()]);
      
      expect(notified, true);
    });

    test('MockSimulationService should handle loading state', () {
      final service = MockSimulationService();
      service.setIsLoading(true);
      
      expect(service.isLoading, true);
      
      service.setIsLoading(false);
      expect(service.isLoading, false);
    });
  });

  group('Dashboard Data Models', () {
    test('User should have correct structure', () {
      final user = MockData.createUser();
      
      expect(user.id, isNotEmpty);
      expect(user.email, contains('@'));
      expect(user.name, isNotEmpty);
    });

    test('Simulation should have correct structure', () {
      final simulation = MockData.createSimulation(id: 'test-sim');
      
      expect(simulation.id, 'test-sim');
      expect(simulation.name, isNotEmpty);
    });

    test('UsageStats should have correct structure', () {
      final stats = UsageStats(
        totalSimulations: 100,
        storageUsed: 500,
        lastSimulationAt: DateTime.now(),
      );
      
      expect(stats.totalSimulations, 100);
      expect(stats.storageUsed, 500);
    });

    test('SimulationStatus enum should have all values', () {
      expect(SimulationStatus.values.length, greaterThanOrEqualTo(3));
      expect(SimulationStatus.values.contains(SimulationStatus.draft), true);
      expect(SimulationStatus.values.contains(SimulationStatus.completed), true);
    });

    test('StructureType enum should have all values', () {
      expect(StructureType.values.length, greaterThanOrEqualTo(3));
    });
  });

  group('Dashboard Simulation List', () {
    test('should handle empty simulation list', () {
      final service = MockSimulationService();
      expect(service.simulations, isEmpty);
      expect(service.simulations.isEmpty, true);
    });

    test('should handle multiple simulations', () {
      final service = MockSimulationService();
      final simulations = MockData.createSimulations(count: 10);
      service.setSimulations(simulations);
      
      expect(service.simulations.length, 10);
      expect(service.simulations.isNotEmpty, true);
    });

    test('should filter simulations by status', () {
      final simulations = [
        Simulation(
          id: '1',
          userId: 'user-1',
          name: 'Draft Sim',
          description: 'Test',
          status: SimulationStatus.draft,
          params: const SimulationParams(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Simulation(
          id: '2',
          userId: 'user-1',
          name: 'Completed Sim',
          description: 'Test',
          status: SimulationStatus.completed,
          params: const SimulationParams(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      final draft = simulations.where((s) => s.status == SimulationStatus.draft).toList();
      final completed = simulations.where((s) => s.status == SimulationStatus.completed).toList();
      
      expect(draft.length, 1);
      expect(completed.length, 1);
    });
  });

  group('Dashboard Navigation', () {
    test('MockSimulationService should handle navigation to simulation', () {
      final service = MockSimulationService();
      final simulation = MockData.createSimulation(id: 'nav-sim');
      
      service.setCurrentSimulation(simulation);
      expect(service.currentSimulation?.id, 'nav-sim');
    });

    test('MockSimulationService should clear current simulation', () {
      final service = MockSimulationService();
      final simulation = MockData.createSimulation();
      
      service.setCurrentSimulation(simulation);
      expect(service.currentSimulation, isNotNull);
      
      service.setCurrentSimulation(null);
      expect(service.currentSimulation, isNull);
    });
  });

  group('Dashboard Statistics', () {
    test('should calculate simulation count', () {
      final simulations = MockData.createSimulations(count: 7);
      expect(simulations.length, 7);
    });

    test('should calculate completed simulations', () {
      final simulations = [
        MockData.createSimulation(id: '1'),
        MockData.createSimulation(id: '2'),
      ];
      // All mocked simulations are completed by default
      final completed = simulations.where((s) => s.status == SimulationStatus.completed);
      expect(completed.length, 2);
    });

    test('UsageStats should track storage correctly', () {
      final stats = UsageStats(
        totalSimulations: 50,
        storageUsed: 2048,
        lastSimulationAt: DateTime.now(),
      );
      
      expect(stats.totalSimulations, 50);
      expect(stats.storageUsed, 2048);
    });
  });

  group('Dashboard User Profile', () {
    test('should display user information', () {
      final user = MockData.createUser();
      
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
    });

    test('should handle user roles', () {
      expect(UserRole.values.length, greaterThanOrEqualTo(2));
      expect(UserRole.user, isNotNull);
    });

    test('should handle subscription plans', () {
      expect(SubscriptionPlan.values.length, greaterThanOrEqualTo(2));
      expect(SubscriptionPlan.free, isNotNull);
    });
  });

  group('Dashboard Search and Filter', () {
    test('should filter simulations by name', () {
      final simulations = [
        MockData.createSimulation(id: '1'),
        MockData.createSimulation(id: '2'),
      ];
      
      final searchTerm = 'simulation';
      final filtered = simulations.where(
        (s) => s.name.toLowerCase().contains(searchTerm.toLowerCase())
      ).toList();
      
      expect(filtered.length, 2); // Both contain 'simulation'
    });

    test('should sort simulations by date', () {
      final now = DateTime.now();
      final simulations = [
        Simulation(
          id: '1',
          userId: 'user-1',
          name: 'Old Sim',
          description: 'Test',
          status: SimulationStatus.completed,
          params: const SimulationParams(),
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
        Simulation(
          id: '2',
          userId: 'user-1',
          name: 'New Sim',
          description: 'Test',
          status: SimulationStatus.completed,
          params: const SimulationParams(),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      
      simulations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      expect(simulations.first.id, '2');
      expect(simulations.last.id, '1');
    });
  });
}
