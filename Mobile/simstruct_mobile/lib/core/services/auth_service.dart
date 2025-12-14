import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'notification_service.dart';

/// Authentication State
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth Service - Handles authentication with real backend
class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  SharedPreferences? _prefs;
  final ApiService _apiService = ApiService();
  
  // Notification service for showing welcome toast
  NotificationService? _notificationService;
  
  // Set notification service (called from main.dart)
  void setNotificationService(NotificationService service) {
    _notificationService = service;
  }

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
        // Restore token to API service
        await _apiService.saveToken(_token!);
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

  /// Sign in with email and password - REAL BACKEND CALL
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Make real API call to backend
      final response = await _apiService.post(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
        withAuth: false, // No token needed for login
      );

      debugPrint('Login response: $response');

      if (response.success && response.data != null) {
        // Parse response data
        final data = response.data;
        
        // Get token
        _token = data['accessToken'];
        
        // Save token to API service for future requests
        if (_token != null) {
          await _apiService.saveToken(_token!);
        }
        
        // Parse user data
        final userData = data['user'];
        if (userData != null) {
          _user = _parseUserFromBackend(userData);
        }

        // Save to local storage
        await _saveAuth();
        _setState(AuthState.authenticated);
        _setLoading(false);
        
        // Show welcome notification
        if (_notificationService != null && _user != null) {
          _notificationService!.showSuccess(
            'Welcome back, ${_user!.firstName}! 👋',
          );
        }
        
        return true;
      } else {
        // Login failed
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with email and password - REAL BACKEND CALL
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Make real API call to backend
      final response = await _apiService.post(
        ApiConfig.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
        withAuth: false, // No token needed for register
      );

      debugPrint('Register response: $response');

      if (response.success && response.data != null) {
        // Parse response data
        final data = response.data;
        
        // Get token
        _token = data['accessToken'];
        
        // Save token to API service
        if (_token != null) {
          await _apiService.saveToken(_token!);
        }
        
        // Parse user data
        final userData = data['user'];
        if (userData != null) {
          _user = _parseUserFromBackend(userData);
        }

        // Save to local storage
        await _saveAuth();
        _setState(AuthState.authenticated);
        _setLoading(false);
        
        // Show welcome notification for new user
        if (_notificationService != null && _user != null) {
          _notificationService!.showSuccess(
            'Welcome to SimStruct, ${_user!.firstName}! 🎉',
          );
        }
        
        return true;
      } else {
        // Registration failed
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Register error: $e');
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  /// Parse user from backend response
  User _parseUserFromBackend(Map<String, dynamic> userData) {
    return User(
      id: userData['id'] ?? '',
      email: userData['email'] ?? '',
      name: userData['name'] ?? '',
      role: _parseRole(userData['role']),
      subscriptionPlan: SubscriptionPlan.free,
      emailVerified: userData['emailVerified'] ?? false,
      createdAt: userData['createdAt'] != null 
          ? DateTime.parse(userData['createdAt']) 
          : DateTime.now(),
      updatedAt: DateTime.now(),
      profile: UserProfile(
        avatarUrl: userData['avatarUrl'],
        phone: userData['phone'],
        company: userData['company'],
        jobTitle: userData['jobTitle'],
        bio: userData['bio'],
      ),
    );
  }

  /// Parse role from string
  UserRole _parseRole(String? role) {
    if (role == null) return UserRole.user;
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'PRO':
        return UserRole.pro;
      default:
        return UserRole.user;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      // Call backend logout (optional, JWT is stateless)
      await _apiService.post(ApiConfig.logout, withAuth: true);
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }

    // Clear token from API service
    await _apiService.deleteToken();
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
      // TODO: Implement when backend has this endpoint
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
      // TODO: Implement with real API when needed
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
      // TODO: Implement with real API when needed
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
