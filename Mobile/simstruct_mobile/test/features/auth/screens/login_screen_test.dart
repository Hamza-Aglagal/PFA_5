import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/services/auth_service.dart';
import '../../../helpers/mocks.dart';

void main() {
  group('LoginScreen Unit Tests', () {
    test('AuthState enum should have all values', () {
      expect(AuthState.values.length, 5);
      expect(AuthState.initial.name, 'initial');
      expect(AuthState.loading.name, 'loading');
      expect(AuthState.authenticated.name, 'authenticated');
      expect(AuthState.unauthenticated.name, 'unauthenticated');
      expect(AuthState.error.name, 'error');
    });

    test('MockAuthService should start unauthenticated', () {
      final authService = MockAuthService();
      expect(authService.state, AuthState.unauthenticated);
      expect(authService.isAuthenticated, false);
    });

    test('MockAuthService should update state when user is set', () {
      final authService = MockAuthService();
      authService.setUser(MockData.createUser());
      
      expect(authService.state, AuthState.authenticated);
      expect(authService.isAuthenticated, true);
    });

    test('MockAuthService signIn should return true', () async {
      final authService = MockAuthService();
      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(result, true);
    });

    test('MockAuthService signUp should return true', () async {
      final authService = MockAuthService();
      final result = await authService.signUp(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );
      expect(result, true);
    });

    test('MockAuthService signOut should clear user', () async {
      final authService = MockAuthService();
      authService.setUser(MockData.createUser());
      expect(authService.isAuthenticated, true);
      
      await authService.signOut();
      
      expect(authService.isAuthenticated, false);
      expect(authService.user, isNull);
    });

    test('MockAuthService should notify listeners on state change', () {
      final authService = MockAuthService();
      var notified = false;
      authService.addListener(() => notified = true);
      
      authService.setUser(MockData.createUser());
      
      expect(notified, true);
    });

    test('MockAuthService updateProfile should return true', () async {
      final authService = MockAuthService();
      final result = await authService.updateProfile(name: 'New Name');
      expect(result, true);
    });

    test('MockAuthService changePassword should return true', () async {
      final authService = MockAuthService();
      final result = await authService.changePassword(
        currentPassword: 'old',
        newPassword: 'new',
      );
      expect(result, true);
    });

    test('MockAuthService deleteAccount should return true', () async {
      final authService = MockAuthService();
      final result = await authService.deleteAccount();
      expect(result, true);
    });

    test('MockAuthService resetPassword should return true', () async {
      final authService = MockAuthService();
      final result = await authService.resetPassword(email: 'test@example.com');
      expect(result, true);
    });
  });

  group('Login Form Validation', () {
    test('email validation - empty email', () {
      const email = '';
      final isValid = email.isNotEmpty && 
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      expect(isValid, false);
    });

    test('email validation - invalid email', () {
      const email = 'invalid-email';
      final isValid = email.isNotEmpty && 
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      expect(isValid, false);
    });

    test('email validation - valid email', () {
      const email = 'test@example.com';
      final isValid = email.isNotEmpty && 
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      expect(isValid, true);
    });

    test('password validation - empty password', () {
      const password = '';
      final isValid = password.isNotEmpty && password.length >= 6;
      expect(isValid, false);
    });

    test('password validation - too short password', () {
      const password = '12345';
      final isValid = password.isNotEmpty && password.length >= 6;
      expect(isValid, false);
    });

    test('password validation - valid password', () {
      const password = 'password123';
      final isValid = password.isNotEmpty && password.length >= 6;
      expect(isValid, true);
    });
  });
}
