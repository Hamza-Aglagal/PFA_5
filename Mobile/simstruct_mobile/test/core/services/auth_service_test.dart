import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/services/auth_service.dart';
import 'package:simstruct_mobile/core/models/user.dart';
import '../../helpers/mocks.dart';

void main() {
  group('AuthState', () {
    test('should have all enum values', () {
      expect(AuthState.values.length, 5);
      expect(AuthState.initial.name, 'initial');
      expect(AuthState.loading.name, 'loading');
      expect(AuthState.authenticated.name, 'authenticated');
      expect(AuthState.unauthenticated.name, 'unauthenticated');
      expect(AuthState.error.name, 'error');
    });
  });

  group('MockAuthService', () {
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
    });

    test('should start with unauthenticated state', () {
      expect(authService.state, AuthState.unauthenticated);
      expect(authService.isAuthenticated, false);
    });

    test('should start with no user', () {
      expect(authService.user, isNull);
    });

    test('should start with no token', () {
      expect(authService.token, isNull);
    });

    test('should start with no error', () {
      expect(authService.error, isNull);
    });

    test('should start with not loading', () {
      expect(authService.isLoading, false);
    });

    test('setUser should update user and state', () {
      final user = MockData.createUser();
      authService.setUser(user);

      expect(authService.user, isNotNull);
      expect(authService.user!.id, 'user-1');
      expect(authService.state, AuthState.authenticated);
      expect(authService.isAuthenticated, true);
    });

    test('setUser with null should set unauthenticated state', () {
      final user = MockData.createUser();
      authService.setUser(user);
      authService.setUser(null);

      expect(authService.user, isNull);
      expect(authService.state, AuthState.unauthenticated);
      expect(authService.isAuthenticated, false);
    });

    test('setLoading should update loading state', () {
      authService.setLoading(true);
      expect(authService.isLoading, true);

      authService.setLoading(false);
      expect(authService.isLoading, false);
    });

    test('setError should update error message', () {
      authService.setError('Something went wrong');
      expect(authService.error, 'Something went wrong');

      authService.setError(null);
      expect(authService.error, isNull);
    });

    test('signIn should return true', () async {
      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(result, true);
    });

    test('signUp should return true', () async {
      final result = await authService.signUp(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );
      expect(result, true);
    });

    test('signOut should clear user and token', () async {
      final user = MockData.createUser();
      authService.setUser(user);
      
      await authService.signOut();

      expect(authService.user, isNull);
      expect(authService.token, isNull);
      expect(authService.state, AuthState.unauthenticated);
    });

    test('updateProfile should return true', () async {
      final result = await authService.updateProfile(
        name: 'New Name',
        company: 'New Company',
      );
      expect(result, true);
    });

    test('changePassword should return true', () async {
      final result = await authService.changePassword(
        currentPassword: 'old-password',
        newPassword: 'new-password',
      );
      expect(result, true);
    });

    test('deleteAccount should return true', () async {
      final result = await authService.deleteAccount();
      expect(result, true);
    });

    test('resetPassword should return true', () async {
      final result = await authService.resetPassword(
        email: 'test@example.com',
      );
      expect(result, true);
    });

    test('init should complete without error', () async {
      await expectLater(authService.init(), completes);
    });

    test('refreshUserData should complete without error', () async {
      await expectLater(authService.refreshUserData(), completes);
    });

    test('should notify listeners on state change', () {
      var notificationCount = 0;
      authService.addListener(() {
        notificationCount++;
      });

      authService.setLoading(true);
      expect(notificationCount, 1);

      final user = MockData.createUser();
      authService.setUser(user);
      expect(notificationCount, 2);
    });
  });

  group('AuthService User Integration', () {
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
    });

    test('isAuthenticated should be true when user exists and state is authenticated', () {
      expect(authService.isAuthenticated, false);

      final user = MockData.createUser();
      authService.setUser(user);

      expect(authService.isAuthenticated, true);
    });

    test('isAuthenticated should be false when user is null', () {
      authService.setUser(null);
      expect(authService.isAuthenticated, false);
    });

    test('should support different user roles', () {
      final proUser = MockData.createUser(role: UserRole.pro);
      authService.setUser(proUser);
      
      expect(authService.user!.role, UserRole.pro);

      final adminUser = MockData.createUser(role: UserRole.admin);
      authService.setUser(adminUser);
      
      expect(authService.user!.role, UserRole.admin);
    });

    test('should support different subscription plans', () {
      final freeUser = MockData.createUser(subscriptionPlan: SubscriptionPlan.free);
      authService.setUser(freeUser);
      
      expect(authService.user!.subscriptionPlan, SubscriptionPlan.free);

      final proUser = MockData.createUser(subscriptionPlan: SubscriptionPlan.pro);
      authService.setUser(proUser);
      
      expect(authService.user!.subscriptionPlan, SubscriptionPlan.pro);
    });
  });
}
