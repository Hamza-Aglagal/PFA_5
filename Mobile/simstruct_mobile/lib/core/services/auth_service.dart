import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Authentication State
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth Service - Handles authentication logic (UI-only mock version)
class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  SharedPreferences? _prefs;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _token;
  String? _error;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  /// Initialize the auth service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStoredAuth();
  }

  /// Load stored authentication data
  Future<void> _loadStoredAuth() async {
    _setState(AuthState.loading);
    
    try {
      _token = _prefs?.getString(_tokenKey);
      final userData = _prefs?.getString(_userKey);

      if (_token != null && userData != null) {
        _user = User.fromJson(jsonDecode(userData));
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      debugPrint('Error loading auth: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful login
      if (email.isNotEmpty && password.length >= 6) {
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        _user = User(
          id: 'user_1',
          email: email,
          name: email.split('@').first.replaceAll('.', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
          role: UserRole.user,
          subscriptionPlan: SubscriptionPlan.free,
          emailVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          profile: const UserProfile(
            stats: UsageStats(
              totalSimulations: 5,
              monthlySimulations: 3,
              sharedSimulations: 1,
              completedSimulations: 3,
              failedSimulations: 1,
              storageUsed: 25.5,
            ),
          ),
        );

        await _saveAuth();
        _setState(AuthState.authenticated);
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid email or password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful registration
      if (email.isNotEmpty && password.length >= 8 && name.isNotEmpty) {
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        _user = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          role: UserRole.user,
          subscriptionPlan: SubscriptionPlan.free,
          emailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _saveAuth();
        _setState(AuthState.authenticated);
        _setLoading(false);
        return true;
      } else {
        _setError('Please check your input');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }

    await _clearAuth();
    _setState(AuthState.unauthenticated);
    _setLoading(false);
  }

  /// Logout - alias for signOut
  Future<void> logout() => signOut();

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send reset email');
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? bio,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      _user = _user!.copyWith(
        name: name ?? _user!.name,
        profile: _user!.profile.copyWith(
          phone: phone,
          company: company,
          bio: bio,
        ),
        updatedAt: DateTime.now(),
      );

      await _saveAuth();
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      _setLoading(false);
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to change password');
      _setLoading(false);
      return false;
    }
  }

  /// Save authentication data
  Future<void> _saveAuth() async {
    if (_token != null) {
      await _prefs?.setString(_tokenKey, _token!);
    }
    if (_user != null) {
      await _prefs?.setString(_userKey, jsonEncode(_user!.toJson()));
    }
  }

  /// Clear authentication data
  Future<void> _clearAuth() async {
    _token = null;
    _user = null;
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userKey);
  }

  /// State helpers
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
