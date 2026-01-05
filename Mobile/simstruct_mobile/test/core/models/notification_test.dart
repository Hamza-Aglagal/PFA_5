import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/notification.dart';

void main() {
  group('NotificationType', () {
    test('should have correct colors', () {
      expect(NotificationType.success.color, isA<Color>());
      expect(NotificationType.error.color, isA<Color>());
      expect(NotificationType.warning.color, isA<Color>());
      expect(NotificationType.info.color, isA<Color>());
    });

    test('should have background colors', () {
      expect(NotificationType.success.backgroundColor, isA<Color>());
      expect(NotificationType.error.backgroundColor, isA<Color>());
    });

    test('should have icons', () {
      expect(NotificationType.success.icon, isA<IconData>());
      expect(NotificationType.error.icon, isA<IconData>());
      expect(NotificationType.warning.icon, isA<IconData>());
      expect(NotificationType.info.icon, isA<IconData>());
    });

    test('should have all enum values', () {
      expect(NotificationType.values.length, 4);
    });
  });

  group('NotificationCategory', () {
    test('should have correct display names', () {
      expect(NotificationCategory.simulation.displayName, 'Simulation');
      expect(NotificationCategory.community.displayName, 'Community');
      expect(NotificationCategory.system.displayName, 'System');
      expect(NotificationCategory.account.displayName, 'Account');
    });

    test('should have icons', () {
      expect(NotificationCategory.simulation.icon, isA<IconData>());
      expect(NotificationCategory.community.icon, isA<IconData>());
      expect(NotificationCategory.system.icon, isA<IconData>());
      expect(NotificationCategory.account.icon, isA<IconData>());
    });

    test('should have all enum values', () {
      expect(NotificationCategory.values.length, 4);
    });
  });

  group('AppNotification', () {
    late AppNotification notification;

    setUp(() {
      notification = AppNotification(
        id: 'notif-123',
        type: NotificationType.success,
        title: 'Simulation Complete',
        message: 'Your simulation has finished processing',
        category: NotificationCategory.simulation,
        isRead: false,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );
    });

    test('should create notification with required fields', () {
      expect(notification.id, 'notif-123');
      expect(notification.type, NotificationType.success);
      expect(notification.title, 'Simulation Complete');
      expect(notification.message, 'Your simulation has finished processing');
      expect(notification.category, NotificationCategory.simulation);
      expect(notification.isRead, false);
    });

    test('should create from JSON', () {
      final json = {
        'id': 'notif-456',
        'type': 'error',
        'title': 'Error Occurred',
        'message': 'Something went wrong',
        'category': 'system',
        'isRead': true,
        'createdAt': '2024-01-15T10:30:00.000Z',
        'data': {'key': 'value'},
      };

      final parsedNotification = AppNotification.fromJson(json);
      expect(parsedNotification.id, 'notif-456');
      expect(parsedNotification.type, NotificationType.error);
      expect(parsedNotification.title, 'Error Occurred');
      expect(parsedNotification.isRead, true);
      expect(parsedNotification.data, isNotNull);
    });

    test('should serialize to JSON', () {
      final json = notification.toJson();
      expect(json['id'], 'notif-123');
      expect(json['type'], 'success');
      expect(json['title'], 'Simulation Complete');
      expect(json['isRead'], false);
    });

    test('should support copyWith', () {
      final readNotification = notification.copyWith(isRead: true);
      expect(readNotification.isRead, true);
      expect(readNotification.id, notification.id);
      expect(readNotification.title, notification.title);
    });

    test('should use default category when invalid in JSON', () {
      final json = {
        'id': 'notif-789',
        'type': 'info',
        'title': 'Test',
        'message': 'Test message',
        'category': 'invalid_category',
        'isRead': false,
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      final parsedNotification = AppNotification.fromJson(json);
      expect(parsedNotification.category, NotificationCategory.system);
    });

    test('should use default type when invalid in JSON', () {
      final json = {
        'id': 'notif-789',
        'type': 'invalid_type',
        'title': 'Test',
        'message': 'Test message',
        'category': 'system',
        'isRead': false,
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      final parsedNotification = AppNotification.fromJson(json);
      expect(parsedNotification.type, NotificationType.info);
    });

    test('should have optional actionUrl', () {
      final notificationWithAction = AppNotification(
        id: 'notif-action',
        type: NotificationType.info,
        title: 'View Results',
        message: 'Click to view results',
        actionUrl: '/results/sim-123',
        createdAt: DateTime.now(),
      );

      expect(notificationWithAction.actionUrl, '/results/sim-123');
    });

    test('should handle null data', () {
      expect(notification.data, isNull);
    });

    group('timeAgo', () {
      test('should return "Now" for just created notification', () {
        final recentNotification = AppNotification(
          id: 'notif-now',
          type: NotificationType.info,
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now(),
        );
        expect(recentNotification.timeAgo, equals('Now'));
      });

      test('should return minutes ago for recent notification', () {
        final minutesAgoNotification = AppNotification(
          id: 'notif-min',
          type: NotificationType.info,
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        );
        expect(minutesAgoNotification.timeAgo, equals('15m ago'));
      });

      test('should return hours ago for notification hours old', () {
        final hoursAgoNotification = AppNotification(
          id: 'notif-hour',
          type: NotificationType.info,
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(hoursAgoNotification.timeAgo, equals('3h ago'));
      });

      test('should return days ago for notification days old', () {
        final daysAgoNotification = AppNotification(
          id: 'notif-day',
          type: NotificationType.info,
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(daysAgoNotification.timeAgo, equals('5d ago'));
      });

      test('should return months ago for notification months old', () {
        final monthsAgoNotification = AppNotification(
          id: 'notif-month',
          type: NotificationType.info,
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        );
        expect(monthsAgoNotification.timeAgo, equals('2mo ago'));
      });

      test('should return years ago for notification years old', () {
        final yearsAgoNotification = AppNotification(
          id: 'notif-year',
          type: NotificationType.info,
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now().subtract(const Duration(days: 400)),
        );
        expect(yearsAgoNotification.timeAgo, equals('1y ago'));
      });
    });
  });

  group('ToastNotification', () {
    test('should create toast with required fields', () {
      final toast = ToastNotification(
        id: 'toast-1',
        message: 'Test message',
      );
      
      expect(toast.id, equals('toast-1'));
      expect(toast.message, equals('Test message'));
      expect(toast.type, equals(NotificationType.info));
      expect(toast.title, isNull);
      expect(toast.action, isNull);
      expect(toast.actionLabel, isNull);
    });

    test('should create success toast', () {
      final toast = ToastNotification.success('Operation completed', title: 'Success');
      
      expect(toast.message, equals('Operation completed'));
      expect(toast.title, equals('Success'));
      expect(toast.type, equals(NotificationType.success));
      expect(toast.id, startsWith('toast_'));
    });

    test('should create error toast with longer duration', () {
      final toast = ToastNotification.error('Something went wrong');
      
      expect(toast.message, equals('Something went wrong'));
      expect(toast.type, equals(NotificationType.error));
      expect(toast.duration, equals(const Duration(seconds: 5)));
    });

    test('should create warning toast', () {
      final toast = ToastNotification.warning('Please be careful');
      
      expect(toast.message, equals('Please be careful'));
      expect(toast.type, equals(NotificationType.warning));
      expect(toast.duration, equals(const Duration(seconds: 4)));
    });

    test('should create info toast', () {
      final toast = ToastNotification.info('Just so you know');
      
      expect(toast.message, equals('Just so you know'));
      expect(toast.type, equals(NotificationType.info));
    });

    test('should create welcome toast', () {
      final toast = ToastNotification.welcome('John');
      
      expect(toast.title, equals('Welcome Back! 👋'));
      expect(toast.message, contains('John'));
      expect(toast.type, equals(NotificationType.success));
      expect(toast.id, startsWith('toast_welcome_'));
    });

    test('should create connectionRestored toast', () {
      final toast = ToastNotification.connectionRestored();
      
      expect(toast.title, equals('Connected'));
      expect(toast.message, contains('connection'));
      expect(toast.type, equals(NotificationType.success));
      expect(toast.id, startsWith('toast_connection_'));
    });

    test('should support action and actionLabel', () {
      var actionCalled = false;
      final toast = ToastNotification.success(
        'Click to undo',
        action: () => actionCalled = true,
        actionLabel: 'Undo',
      );
      
      expect(toast.action, isNotNull);
      expect(toast.actionLabel, equals('Undo'));
      toast.action!();
      expect(actionCalled, isTrue);
    });
  });

  group('NotificationSettings', () {
    test('should create with default values', () {
      const settings = NotificationSettings();
      
      expect(settings.pushEnabled, isTrue);
      expect(settings.emailEnabled, isTrue);
      expect(settings.simulationComplete, isTrue);
      expect(settings.communityActivity, isTrue);
      expect(settings.systemUpdates, isTrue);
      expect(settings.marketingEmails, isFalse);
    });

    test('should create with custom values', () {
      const settings = NotificationSettings(
        pushEnabled: false,
        emailEnabled: false,
        simulationComplete: false,
        communityActivity: false,
        systemUpdates: false,
        marketingEmails: true,
      );
      
      expect(settings.pushEnabled, isFalse);
      expect(settings.emailEnabled, isFalse);
      expect(settings.simulationComplete, isFalse);
      expect(settings.communityActivity, isFalse);
      expect(settings.systemUpdates, isFalse);
      expect(settings.marketingEmails, isTrue);
    });

    test('should support copyWith', () {
      const settings = NotificationSettings();
      final updated = settings.copyWith(pushEnabled: false);
      
      expect(updated.pushEnabled, isFalse);
      expect(updated.emailEnabled, isTrue); // Unchanged
    });

    test('should copyWith all fields', () {
      const settings = NotificationSettings();
      final updated = settings.copyWith(
        pushEnabled: false,
        emailEnabled: false,
        simulationComplete: false,
        communityActivity: false,
        systemUpdates: false,
        marketingEmails: true,
      );
      
      expect(updated.pushEnabled, isFalse);
      expect(updated.emailEnabled, isFalse);
      expect(updated.simulationComplete, isFalse);
      expect(updated.communityActivity, isFalse);
      expect(updated.systemUpdates, isFalse);
      expect(updated.marketingEmails, isTrue);
    });

    test('should convert to JSON', () {
      const settings = NotificationSettings(
        pushEnabled: true,
        emailEnabled: false,
        marketingEmails: true,
      );
      
      final json = settings.toJson();
      
      expect(json['pushEnabled'], isTrue);
      expect(json['emailEnabled'], isFalse);
      expect(json['simulationComplete'], isTrue);
      expect(json['communityActivity'], isTrue);
      expect(json['systemUpdates'], isTrue);
      expect(json['marketingEmails'], isTrue);
    });

    test('should create from JSON', () {
      final json = {
        'pushEnabled': false,
        'emailEnabled': true,
        'simulationComplete': false,
        'communityActivity': true,
        'systemUpdates': false,
        'marketingEmails': true,
      };
      
      final settings = NotificationSettings.fromJson(json);
      
      expect(settings.pushEnabled, isFalse);
      expect(settings.emailEnabled, isTrue);
      expect(settings.simulationComplete, isFalse);
      expect(settings.communityActivity, isTrue);
      expect(settings.systemUpdates, isFalse);
      expect(settings.marketingEmails, isTrue);
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final settings = NotificationSettings.fromJson(json);
      
      expect(settings.pushEnabled, isTrue);
      expect(settings.emailEnabled, isTrue);
      expect(settings.simulationComplete, isTrue);
      expect(settings.communityActivity, isTrue);
      expect(settings.systemUpdates, isTrue);
      expect(settings.marketingEmails, isFalse);
    });
  });
}
