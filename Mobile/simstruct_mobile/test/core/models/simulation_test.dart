import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/simulation.dart';
import 'package:simstruct_mobile/core/models/simulation_params.dart';

void main() {
  group('SimulationStatus', () {
    test('should have correct display names', () {
      expect(SimulationStatus.draft.displayName, 'Draft');
      expect(SimulationStatus.running.displayName, 'Running');
      expect(SimulationStatus.completed.displayName, 'Completed');
      expect(SimulationStatus.failed.displayName, 'Failed');
    });

    test('should have all enum values', () {
      expect(SimulationStatus.values.length, 4);
    });

    test('should have colors', () {
      expect(SimulationStatus.draft.color, isA<Color>());
      expect(SimulationStatus.running.color, isA<Color>());
      expect(SimulationStatus.completed.color, isA<Color>());
      expect(SimulationStatus.failed.color, isA<Color>());
    });

    test('should have icons', () {
      expect(SimulationStatus.draft.icon, isA<IconData>());
      expect(SimulationStatus.running.icon, isA<IconData>());
      expect(SimulationStatus.completed.icon, isA<IconData>());
      expect(SimulationStatus.failed.icon, isA<IconData>());
    });
  });

  group('ResultStatus', () {
    test('should have correct display names', () {
      expect(ResultStatus.safe.displayName, 'Safe');
      expect(ResultStatus.warning.displayName, 'Warning');
      expect(ResultStatus.critical.displayName, 'Critical');
    });

    test('should have descriptions', () {
      expect(ResultStatus.safe.description, contains('safety'));
      expect(ResultStatus.warning.description, contains('Caution'));
      expect(ResultStatus.critical.description, contains('not meet'));
    });

    test('should have colors', () {
      expect(ResultStatus.safe.color, isA<Color>());
      expect(ResultStatus.warning.color, isA<Color>());
      expect(ResultStatus.critical.color, isA<Color>());
    });

    test('should have icons', () {
      expect(ResultStatus.safe.icon, isA<IconData>());
      expect(ResultStatus.warning.icon, isA<IconData>());
      expect(ResultStatus.critical.icon, isA<IconData>());
    });
  });

  group('StructureType', () {
    test('should have correct display names', () {
      expect(StructureType.beam.displayName, 'Beam');
      expect(StructureType.frame.displayName, 'Frame');
      expect(StructureType.truss.displayName, 'Truss');
      expect(StructureType.column.displayName, 'Column');
    });

    test('should have descriptions', () {
      expect(StructureType.beam.description, contains('beam'));
      expect(StructureType.frame.description, contains('frame'));
    });

    test('should have icons', () {
      expect(StructureType.beam.icon, isNotEmpty);
      expect(StructureType.beam.iconData, isA<IconData>());
    });
  });

  group('StructuralMaterial', () {
    test('should have correct display names', () {
      expect(StructuralMaterial.steel.displayName, 'Steel');
      expect(StructuralMaterial.concrete.displayName, 'Concrete');
      expect(StructuralMaterial.aluminum.displayName, 'Aluminum');
      expect(StructuralMaterial.wood.displayName, 'Wood');
    });

    test('should have colors', () {
      expect(StructuralMaterial.steel.color, isA<Color>());
      expect(StructuralMaterial.concrete.color, isA<Color>());
    });

    test('should have descriptions', () {
      expect(StructuralMaterial.steel.description, contains('strength'));
    });
  });

  group('AnalysisResult', () {
    test('should calculate status from safety factor - safe', () {
      final status = AnalysisResult.calculateStatus(2.5);
      expect(status, ResultStatus.safe);
    });

    test('should calculate status from safety factor - warning', () {
      final status = AnalysisResult.calculateStatus(1.7);
      expect(status, ResultStatus.warning);
    });

    test('should calculate status from safety factor - critical', () {
      final status = AnalysisResult.calculateStatus(1.0);
      expect(status, ResultStatus.critical);
    });

    test('should create from JSON', () {
      final json = {
        'safetyFactor': 2.5,
        'maxDeflection': 0.05,
        'maxStress': 150.0,
        'bucklingLoad': 500.0,
        'naturalFrequency': 10.0,
        'status': 'safe',
        'recommendations': ['Increase beam thickness'],
      };

      final result = AnalysisResult.fromJson(json);
      expect(result.safetyFactor, 2.5);
      expect(result.maxDeflection, 0.05);
      expect(result.maxStress, 150.0);
      expect(result.status, ResultStatus.safe);
      expect(result.recommendations.length, 1);
    });

    test('should serialize to JSON', () {
      const result = AnalysisResult(
        safetyFactor: 2.5,
        maxDeflection: 0.05,
        maxStress: 150.0,
        bucklingLoad: 500.0,
        naturalFrequency: 10.0,
        status: ResultStatus.safe,
      );

      final json = result.toJson();
      expect(json['safetyFactor'], 2.5);
      expect(json['status'], 'safe');
    });

    test('should check hasAIPredictions', () {
      const result = AnalysisResult(
        safetyFactor: 2.0,
        maxDeflection: 0.05,
        maxStress: 150.0,
        bucklingLoad: 500.0,
        naturalFrequency: 10.0,
        status: ResultStatus.safe,
        stabilityIndex: 0.95,
      );

      expect(result.hasAIPredictions, true);
    });

    test('should handle missing values in JSON', () {
      final json = <String, dynamic>{};
      final result = AnalysisResult.fromJson(json);
      expect(result.safetyFactor, 0.0);
      expect(result.status, ResultStatus.warning);
    });
  });

  group('StressPoint', () {
    test('should create from JSON', () {
      final json = {
        'position': 0.5,
        'stress': 100.0,
        'normalizedStress': 0.75,
      };

      final point = StressPoint.fromJson(json);
      expect(point.position, 0.5);
      expect(point.stress, 100.0);
      expect(point.normalizedStress, 0.75);
    });

    test('should serialize to JSON', () {
      const point = StressPoint(position: 0.5, stress: 100.0, normalizedStress: 0.75);
      final json = point.toJson();
      expect(json['position'], 0.5);
      expect(json['stress'], 100.0);
      expect(json['normalizedStress'], 0.75);
    });
  });

  group('DeflectionPoint', () {
    test('should create from JSON', () {
      final json = {
        'position': 0.5,
        'deflection': 0.02,
      };

      final point = DeflectionPoint.fromJson(json);
      expect(point.position, 0.5);
      expect(point.deflection, 0.02);
    });

    test('should serialize to JSON', () {
      const point = DeflectionPoint(position: 0.5, deflection: 0.02);
      final json = point.toJson();
      expect(json['position'], 0.5);
      expect(json['deflection'], 0.02);
    });
  });

  group('AIInsight', () {
    test('should create from JSON', () {
      final json = {
        'summary': 'Structure is stable',
        'keyFindings': ['Finding 1', 'Finding 2'],
        'improvements': ['Improvement 1'],
        'confidenceScore': 0.95,
        'generatedAt': '2024-01-15T10:00:00.000Z',
      };

      final insight = AIInsight.fromJson(json);
      expect(insight.summary, 'Structure is stable');
      expect(insight.keyFindings.length, 2);
      expect(insight.improvements.length, 1);
      expect(insight.confidenceScore, 0.95);
    });

    test('should serialize to JSON', () {
      final insight = AIInsight(
        summary: 'Test summary',
        keyFindings: ['Finding'],
        improvements: ['Improvement'],
        confidenceScore: 0.9,
        generatedAt: DateTime(2024, 1, 15),
      );

      final json = insight.toJson();
      expect(json['summary'], 'Test summary');
      expect(json['confidenceScore'], 0.9);
    });
  });

  group('Simulation', () {
    late Simulation simulation;

    setUp(() {
      simulation = Simulation(
        id: 'sim-123',
        name: 'Test Simulation',
        description: 'A test simulation',
        userId: 'user-1',
        params: SimulationParams(
          structureType: StructureType.beam,
          material: StructuralMaterial.steel,
        ),
        status: SimulationStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
        result: const AnalysisResult(
          safetyFactor: 2.5,
          maxDeflection: 0.05,
          maxStress: 150.0,
          bucklingLoad: 500.0,
          naturalFrequency: 10.0,
          status: ResultStatus.safe,
        ),
      );
    });

    test('should create simulation with required fields', () {
      expect(simulation.id, 'sim-123');
      expect(simulation.name, 'Test Simulation');
      expect(simulation.status, SimulationStatus.completed);
    });

    test('should check hasResult correctly', () {
      expect(simulation.hasResult, true);

      final draftSimulation = Simulation(
        id: 'sim-2',
        name: 'Draft Sim',
        userId: 'user-1',
        params: SimulationParams(
          structureType: StructureType.beam,
          material: StructuralMaterial.steel,
        ),
        status: SimulationStatus.draft,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(draftSimulation.hasResult, false);
    });

    test('should get subtitle correctly', () {
      expect(simulation.subtitle, contains('Beam'));
      expect(simulation.subtitle, contains('Steel'));
    });

    test('should return isPublic as alias for isShared', () {
      expect(simulation.isPublic, simulation.isShared);
    });

    test('should have tags default to empty list', () {
      expect(simulation.tags, isEmpty);
    });

    test('should have isFavorite default to false', () {
      expect(simulation.isFavorite, false);
    });

    group('timeAgo', () {
      test('should return "Just now" for recent simulation', () {
        final recentSim = Simulation(
          id: 'sim-1',
          name: 'Test',
          userId: 'user-1',
          params: SimulationParams(
            structureType: StructureType.beam,
            material: StructuralMaterial.steel,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(recentSim.timeAgo, equals('Just now'));
      });

      test('should return minutes for simulation minutes old', () {
        final sim = Simulation(
          id: 'sim-1',
          name: 'Test',
          userId: 'user-1',
          params: SimulationParams(
            structureType: StructureType.beam,
            material: StructuralMaterial.steel,
          ),
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          updatedAt: DateTime.now(),
        );
        expect(sim.timeAgo, equals('30 minute(s) ago'));
      });

      test('should return hours for simulation hours old', () {
        final sim = Simulation(
          id: 'sim-1',
          name: 'Test',
          userId: 'user-1',
          params: SimulationParams(
            structureType: StructureType.beam,
            material: StructuralMaterial.steel,
          ),
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          updatedAt: DateTime.now(),
        );
        expect(sim.timeAgo, equals('5 hour(s) ago'));
      });

      test('should return days for simulation days old', () {
        final sim = Simulation(
          id: 'sim-1',
          name: 'Test',
          userId: 'user-1',
          params: SimulationParams(
            structureType: StructureType.beam,
            material: StructuralMaterial.steel,
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        );
        expect(sim.timeAgo, equals('3 day(s) ago'));
      });

      test('should return months for simulation months old', () {
        final sim = Simulation(
          id: 'sim-1',
          name: 'Test',
          userId: 'user-1',
          params: SimulationParams(
            structureType: StructureType.beam,
            material: StructuralMaterial.steel,
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
        );
        expect(sim.timeAgo, equals('2 month(s) ago'));
      });

      test('should return years for simulation years old', () {
        final sim = Simulation(
          id: 'sim-1',
          name: 'Test',
          userId: 'user-1',
          params: SimulationParams(
            structureType: StructureType.beam,
            material: StructuralMaterial.steel,
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 400)),
          updatedAt: DateTime.now(),
        );
        expect(sim.timeAgo, equals('1 year(s) ago'));
      });
    });

    test('should support copyWith', () {
      final updated = simulation.copyWith(name: 'Updated Name');
      expect(updated.name, equals('Updated Name'));
      expect(updated.id, equals(simulation.id)); // Unchanged
      expect(updated.status, equals(simulation.status));
    });

    test('should copyWith all fields', () {
      final updated = simulation.copyWith(
        id: 'new-id',
        name: 'New Name',
        description: 'New Description',
        userId: 'new-user',
        status: SimulationStatus.running,
        isFavorite: true,
        isShared: true,
        tags: ['tag1', 'tag2'],
      );
      
      expect(updated.id, equals('new-id'));
      expect(updated.name, equals('New Name'));
      expect(updated.description, equals('New Description'));
      expect(updated.userId, equals('new-user'));
      expect(updated.status, equals(SimulationStatus.running));
      expect(updated.isFavorite, isTrue);
      expect(updated.isShared, isTrue);
      expect(updated.tags, equals(['tag1', 'tag2']));
    });

    test('should convert to JSON', () {
      final json = simulation.toJson();
      
      expect(json['id'], equals('sim-123'));
      expect(json['name'], equals('Test Simulation'));
      expect(json['description'], equals('A test simulation'));
      expect(json['userId'], equals('user-1'));
      expect(json['status'], equals('completed'));
      expect(json['isFavorite'], isFalse);
      expect(json['isShared'], isFalse);
      expect(json['params'], isA<Map>());
      expect(json['result'], isA<Map>());
    });

    test('should create from JSON', () {
      final json = {
        'id': 'sim-456',
        'name': 'JSON Simulation',
        'description': 'From JSON',
        'userId': 'user-2',
        'params': {
          'structureType': 'frame',
          'material': 'concrete',
          'length': 10.0,
          'width': 5.0,
          'height': 3.0,
          'elasticModulus': 30000.0,
          'density': 2400.0,
          'yieldStrength': 25.0,
          'loadType': 'distributed',
          'loadMagnitude': 50.0,
          'loadPosition': 5.0,
        },
        'status': 'running',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'updatedAt': '2024-01-15T12:00:00.000Z',
        'isFavorite': true,
        'isShared': true,
        'tags': ['important', 'test'],
      };
      
      final sim = Simulation.fromJson(json);
      
      expect(sim.id, equals('sim-456'));
      expect(sim.name, equals('JSON Simulation'));
      expect(sim.description, equals('From JSON'));
      expect(sim.status, equals(SimulationStatus.running));
      expect(sim.isFavorite, isTrue);
      expect(sim.isShared, isTrue);
      expect(sim.tags, contains('important'));
    });

    test('should create with Simulation.create factory', () {
      final newSim = Simulation.create(
        userId: 'user-1',
        name: 'New Simulation',
      );
      
      expect(newSim.id, startsWith('sim_'));
      expect(newSim.name, equals('New Simulation'));
      expect(newSim.userId, equals('user-1'));
      expect(newSim.status, equals(SimulationStatus.draft));
    });

    test('should create with Simulation.create factory using default name', () {
      final newSim = Simulation.create(userId: 'user-1');
      
      expect(newSim.name, contains('Simulation'));
      expect(newSim.name, contains('/'));
    });
  });

  group('SimulationSummary', () {
    test('should create from Simulation', () {
      final simulation = Simulation(
        id: 'sim-123',
        name: 'Test Simulation',
        userId: 'user-1',
        params: SimulationParams(
          structureType: StructureType.beam,
          material: StructuralMaterial.steel,
        ),
        status: SimulationStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
        isFavorite: true,
        result: const AnalysisResult(
          safetyFactor: 2.5,
          maxDeflection: 0.05,
          maxStress: 150.0,
          bucklingLoad: 500.0,
          naturalFrequency: 10.0,
          status: ResultStatus.safe,
        ),
      );
      
      final summary = SimulationSummary.fromSimulation(simulation);
      
      expect(summary.id, equals('sim-123'));
      expect(summary.name, equals('Test Simulation'));
      expect(summary.structureType, equals(StructureType.beam));
      expect(summary.material, equals(StructuralMaterial.steel));
      expect(summary.status, equals(SimulationStatus.completed));
      expect(summary.resultStatus, equals(ResultStatus.safe));
      expect(summary.isFavorite, isTrue);
    });

    test('should create from JSON', () {
      final json = {
        'id': 'sim-456',
        'name': 'Summary Test',
        'structureType': 'frame',
        'material': 'concrete',
        'status': 'running',
        'resultStatus': 'warning',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'isFavorite': true,
      };
      
      final summary = SimulationSummary.fromJson(json);
      
      expect(summary.id, equals('sim-456'));
      expect(summary.name, equals('Summary Test'));
      expect(summary.structureType, equals(StructureType.frame));
      expect(summary.material, equals(StructuralMaterial.concrete));
      expect(summary.status, equals(SimulationStatus.running));
      expect(summary.resultStatus, equals(ResultStatus.warning));
      expect(summary.isFavorite, isTrue);
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final summary = SimulationSummary.fromJson(json);
      
      expect(summary.id, equals(''));
      expect(summary.name, equals(''));
      expect(summary.structureType, equals(StructureType.beam));
      expect(summary.material, equals(StructuralMaterial.steel));
      expect(summary.status, equals(SimulationStatus.draft));
      expect(summary.resultStatus, isNull);
      expect(summary.isFavorite, isFalse);
    });

    test('should handle null resultStatus in JSON', () {
      final json = {
        'id': 'sim-789',
        'name': 'Test',
        'structureType': 'beam',
        'material': 'steel',
        'status': 'draft',
        'createdAt': '2024-01-15T10:00:00.000Z',
      };
      
      final summary = SimulationSummary.fromJson(json);
      
      expect(summary.resultStatus, isNull);
    });
  });
}
