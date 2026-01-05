// SimStruct Mobile App Tests
//
// Comprehensive test suite for the SimStruct mobile application

import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/user.dart';
import 'package:simstruct_mobile/core/models/simulation.dart';
import 'package:simstruct_mobile/core/models/simulation_params.dart';
import 'package:simstruct_mobile/core/models/notification.dart';

void main() {
  group('App Smoke Tests', () {
    test('Flutter test framework works', () {
      expect(true, isTrue);
    });

    test('Basic Flutter imports work', () {
      expect(MaterialApp, isNotNull);
      expect(Scaffold, isNotNull);
      expect(Container, isNotNull);
    });
  });

  group('Model Import Tests', () {
    test('User model imports correctly', () {
      expect(UserRole.values, isNotEmpty);
      expect(SubscriptionPlan.values, isNotEmpty);
    });

    test('Simulation model imports correctly', () {
      expect(SimulationStatus.values, isNotEmpty);
      expect(ResultStatus.values, isNotEmpty);
    });

    test('SimulationParams model imports correctly', () {
      expect(StructureType.values, isNotEmpty);
      expect(StructuralMaterial.values, isNotEmpty);
    });

    test('Notification model imports correctly', () {
      expect(NotificationType.values, isNotEmpty);
      expect(NotificationCategory.values, isNotEmpty);
    });
  });

  group('Enum Value Tests', () {
    test('UserRole has expected values', () {
      expect(UserRole.user.name, 'user');
      expect(UserRole.pro.name, 'pro');
      expect(UserRole.admin.name, 'admin');
    });

    test('SubscriptionPlan has expected values', () {
      expect(SubscriptionPlan.free.name, 'free');
      expect(SubscriptionPlan.pro.name, 'pro');
      expect(SubscriptionPlan.enterprise.name, 'enterprise');
    });

    test('SimulationStatus has expected values', () {
      expect(SimulationStatus.draft.name, 'draft');
      expect(SimulationStatus.running.name, 'running');
      expect(SimulationStatus.completed.name, 'completed');
      expect(SimulationStatus.failed.name, 'failed');
    });

    test('StructureType has expected values', () {
      expect(StructureType.beam.name, 'beam');
      expect(StructureType.frame.name, 'frame');
      expect(StructureType.truss.name, 'truss');
      expect(StructureType.column.name, 'column');
    });

    test('StructuralMaterial has expected values', () {
      expect(StructuralMaterial.steel.name, 'steel');
      expect(StructuralMaterial.concrete.name, 'concrete');
      expect(StructuralMaterial.aluminum.name, 'aluminum');
      expect(StructuralMaterial.wood.name, 'wood');
    });
  });

  group('User Model Creation Tests', () {
    test('can create User instance', () {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        subscriptionPlan: SubscriptionPlan.free,
        emailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, UserRole.user);
    });

    test('can create UsageStats instance', () {
      final stats = UsageStats(
        totalSimulations: 5,
        storageUsed: 1024,
        lastSimulationAt: DateTime(2024, 1, 1),
      );

      expect(stats.totalSimulations, 5);
      expect(stats.storageUsed, 1024);
    });

    test('can create UserProfile instance', () {
      final profile = UserProfile(
        phone: '+1234567890',
        company: 'Test Company',
        jobTitle: 'Engineer',
        bio: 'Test bio',
      );

      expect(profile.phone, '+1234567890');
      expect(profile.company, 'Test Company');
    });
  });

  group('Simulation Model Creation Tests', () {
    test('can create Simulation instance', () {
      final simulation = Simulation(
        id: 'sim-1',
        userId: 'user-1',
        name: 'Test Simulation',
        description: 'A test simulation',
        status: SimulationStatus.completed,
        params: const SimulationParams(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(simulation.id, 'sim-1');
      expect(simulation.name, 'Test Simulation');
      expect(simulation.status, SimulationStatus.completed);
    });

    test('can create SimulationParams instance', () {
      const params = SimulationParams(
        length: 10.0,
        width: 2.0,
        height: 1.5,
        material: StructuralMaterial.steel,
        structureType: StructureType.beam,
      );

      expect(params.length, 10.0);
      expect(params.material, StructuralMaterial.steel);
    });

    test('can create AnalysisResult instance', () {
      const result = AnalysisResult(
        maxStress: 250.0,
        maxDeflection: 0.05,
        safetyFactor: 1.5,
        bucklingLoad: 1000.0,
        naturalFrequency: 50.0,
        status: ResultStatus.safe,
      );

      expect(result.maxStress, 250.0);
      expect(result.status, ResultStatus.safe);
    });
  });

  group('Notification Model Creation Tests', () {
    test('can create AppNotification instance', () {
      final notification = AppNotification(
        id: 'notif-1',
        type: NotificationType.success,
        title: 'Test Notification',
        message: 'This is a test',
        category: NotificationCategory.system,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(notification.id, 'notif-1');
      expect(notification.type, NotificationType.success);
      expect(notification.title, 'Test Notification');
    });
  });

  group('Model Serialization Tests', () {
    test('User.fromJson works correctly', () {
      final json = {
        'id': 'user-1',
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'user',
        'subscriptionPlan': 'free',
        'emailVerified': true,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.email, 'test@example.com');
    });

    test('User.toJson works correctly', () {
      final user = User(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        subscriptionPlan: SubscriptionPlan.free,
        emailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], 'user-1');
      expect(json['email'], 'test@example.com');
    });

    test('AppNotification.fromJson works correctly', () {
      final json = {
        'id': 'notif-1',
        'type': 'success',
        'title': 'Test',
        'message': 'Test message',
        'category': 'system',
        'isRead': false,
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.id, 'notif-1');
      expect(notification.type, NotificationType.success);
    });

    test('AppNotification.toJson works correctly', () {
      final notification = AppNotification(
        id: 'notif-1',
        type: NotificationType.success,
        title: 'Test',
        message: 'Test message',
        category: NotificationCategory.system,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = notification.toJson();

      expect(json['id'], 'notif-1');
      expect(json['type'], 'success');
    });
  });

  group('Model Copy Tests', () {
    test('User.copyWith works correctly', () {
      final user = User(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        subscriptionPlan: SubscriptionPlan.free,
        emailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updatedUser = user.copyWith(name: 'Updated Name');

      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.email, 'test@example.com'); // unchanged
    });

    test('AppNotification.copyWith works correctly', () {
      final notification = AppNotification(
        id: 'notif-1',
        type: NotificationType.success,
        title: 'Test',
        message: 'Test message',
        category: NotificationCategory.system,
        isRead: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedNotification = notification.copyWith(isRead: true);

      expect(updatedNotification.isRead, true);
      expect(updatedNotification.title, 'Test'); // unchanged
    });

    test('SimulationParams.copyWith works correctly', () {
      const params = SimulationParams(
        length: 10.0,
        material: StructuralMaterial.steel,
      );

      final updatedParams = params.copyWith(length: 20.0);

      expect(updatedParams.length, 20.0);
      expect(updatedParams.material, StructuralMaterial.steel); // unchanged
    });
  });
}
