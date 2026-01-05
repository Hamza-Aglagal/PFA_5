import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/user.dart';

void main() {
  group('UserRole', () {
    test('should have correct display names', () {
      expect(UserRole.user.displayName, 'Free');
      expect(UserRole.pro.displayName, 'Pro');
      expect(UserRole.admin.displayName, 'Admin');
    });

    test('should have all enum values', () {
      expect(UserRole.values.length, 3);
    });
  });

  group('SubscriptionPlan', () {
    test('should have correct display names', () {
      expect(SubscriptionPlan.free.displayName, 'Free');
      expect(SubscriptionPlan.pro.displayName, 'Pro');
      expect(SubscriptionPlan.enterprise.displayName, 'Enterprise');
    });

    test('should have correct simulations limits', () {
      expect(SubscriptionPlan.free.simulationsLimit, 10);
      expect(SubscriptionPlan.pro.simulationsLimit, 50);
      expect(SubscriptionPlan.enterprise.simulationsLimit, -1);
    });

    test('should have correct storage limits', () {
      expect(SubscriptionPlan.free.storageLimit, 1.0);
      expect(SubscriptionPlan.pro.storageLimit, 5.0);
      expect(SubscriptionPlan.enterprise.storageLimit, 50.0);
    });
  });

  group('UsageStats', () {
    test('should create with default values', () {
      const stats = UsageStats();
      expect(stats.totalSimulations, 0);
      expect(stats.monthlySimulations, 0);
      expect(stats.sharedSimulations, 0);
      expect(stats.completedSimulations, 0);
      expect(stats.failedSimulations, 0);
      expect(stats.storageUsed, 0);
      expect(stats.lastSimulationAt, null);
    });

    test('should create from JSON', () {
      final json = {
        'totalSimulations': 10,
        'monthlySimulations': 5,
        'sharedSimulations': 2,
        'completedSimulations': 8,
        'failedSimulations': 2,
        'storageUsed': 1.5,
        'lastSimulationAt': '2024-01-15T10:30:00.000Z',
      };

      final stats = UsageStats.fromJson(json);
      expect(stats.totalSimulations, 10);
      expect(stats.monthlySimulations, 5);
      expect(stats.sharedSimulations, 2);
      expect(stats.completedSimulations, 8);
      expect(stats.failedSimulations, 2);
      expect(stats.storageUsed, 1.5);
      expect(stats.lastSimulationAt, isNotNull);
    });

    test('should serialize to JSON', () {
      const stats = UsageStats(
        totalSimulations: 10,
        monthlySimulations: 5,
        storageUsed: 1.5,
      );

      final json = stats.toJson();
      expect(json['totalSimulations'], 10);
      expect(json['monthlySimulations'], 5);
      expect(json['storageUsed'], 1.5);
    });

    test('should handle null values in JSON', () {
      final json = <String, dynamic>{};
      final stats = UsageStats.fromJson(json);
      expect(stats.totalSimulations, 0);
      expect(stats.lastSimulationAt, null);
    });
  });

  group('UserProfile', () {
    test('should create with default values', () {
      const profile = UserProfile();
      expect(profile.avatarUrl, null);
      expect(profile.phone, null);
      expect(profile.company, null);
      expect(profile.jobTitle, null);
      expect(profile.bio, null);
      expect(profile.stats, isA<UsageStats>());
    });

    test('should create from JSON', () {
      final json = {
        'avatarUrl': 'https://example.com/avatar.jpg',
        'phone': '+1234567890',
        'company': 'Acme Corp',
        'jobTitle': 'Engineer',
        'bio': 'A software developer',
        'stats': {
          'totalSimulations': 5,
        },
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.phone, '+1234567890');
      expect(profile.company, 'Acme Corp');
      expect(profile.jobTitle, 'Engineer');
      expect(profile.bio, 'A software developer');
      expect(profile.stats.totalSimulations, 5);
    });

    test('should serialize to JSON', () {
      const profile = UserProfile(
        avatarUrl: 'https://example.com/avatar.jpg',
        company: 'Acme Corp',
      );

      final json = profile.toJson();
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
      expect(json['company'], 'Acme Corp');
    });

    test('should support copyWith', () {
      const profile = UserProfile(company: 'Old Company');
      final newProfile = profile.copyWith(company: 'New Company');
      
      expect(profile.company, 'Old Company');
      expect(newProfile.company, 'New Company');
    });
  });

  group('User', () {
    late User user;

    setUp(() {
      user = User(
        id: 'user-123',
        email: 'john.doe@example.com',
        name: 'John Doe',
        role: UserRole.user,
        subscriptionPlan: SubscriptionPlan.free,
        emailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    test('should create user with required fields', () {
      expect(user.id, 'user-123');
      expect(user.email, 'john.doe@example.com');
      expect(user.name, 'John Doe');
      expect(user.role, UserRole.user);
      expect(user.subscriptionPlan, SubscriptionPlan.free);
      expect(user.emailVerified, true);
    });

    test('should get correct initials for two-word name', () {
      expect(user.initials, 'JD');
    });

    test('should get correct initials for single-word name', () {
      final singleNameUser = user.copyWith(name: 'John');
      expect(singleNameUser.initials, 'J');
    });

    test('should get correct initials for multi-word name', () {
      final multiNameUser = user.copyWith(name: 'John Michael Doe');
      expect(multiNameUser.initials, 'JD');
    });

    test('should handle empty name for initials', () {
      final emptyNameUser = user.copyWith(name: '');
      expect(emptyNameUser.initials, '');
    });

    test('should get first name', () {
      expect(user.firstName, 'John');
    });

    test('should get first name for single-word name', () {
      final singleNameUser = user.copyWith(name: 'John');
      expect(singleNameUser.firstName, 'John');
    });

    test('should return isEmailVerified correctly', () {
      expect(user.isEmailVerified, true);
      final unverifiedUser = user.copyWith(emailVerified: false);
      expect(unverifiedUser.isEmailVerified, false);
    });

    test('should create from JSON', () {
      final json = {
        'id': 'user-456',
        'email': 'jane@example.com',
        'name': 'Jane Smith',
        'role': 'pro',
        'subscriptionPlan': 'pro',
        'emailVerified': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-15T00:00:00.000Z',
      };

      final parsedUser = User.fromJson(json);
      expect(parsedUser.id, 'user-456');
      expect(parsedUser.email, 'jane@example.com');
      expect(parsedUser.name, 'Jane Smith');
      expect(parsedUser.role, UserRole.pro);
      expect(parsedUser.subscriptionPlan, SubscriptionPlan.pro);
    });

    test('should use default role when invalid role in JSON', () {
      final json = {
        'id': 'user-456',
        'email': 'jane@example.com',
        'name': 'Jane Smith',
        'role': 'invalid_role',
        'subscriptionPlan': 'free',
        'emailVerified': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-15T00:00:00.000Z',
      };

      final parsedUser = User.fromJson(json);
      expect(parsedUser.role, UserRole.user);
    });

    test('should serialize to JSON', () {
      final json = user.toJson();
      expect(json['id'], 'user-123');
      expect(json['email'], 'john.doe@example.com');
      expect(json['name'], 'John Doe');
      expect(json['role'], 'user');
      expect(json['subscriptionPlan'], 'free');
      expect(json['emailVerified'], true);
    });

    test('should support copyWith', () {
      final updatedUser = user.copyWith(
        name: 'Jane Doe',
        email: 'jane@example.com',
      );

      expect(updatedUser.name, 'Jane Doe');
      expect(updatedUser.email, 'jane@example.com');
      expect(updatedUser.id, user.id); // unchanged
    });

    test('should get avatar URL from profile', () {
      expect(user.avatarUrl, null);
      
      final userWithAvatar = user.copyWith(
        profile: const UserProfile(avatarUrl: 'https://example.com/avatar.jpg'),
      );
      expect(userWithAvatar.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });
}
