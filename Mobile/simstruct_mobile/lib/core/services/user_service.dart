import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

/// User Service - Handles user profile operations with backend
class UserService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Get current user profile from backend
  Future<User?> getProfile() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get(ApiConfig.userMe);
      
      debugPrint('Get profile response: $response');
      
      if (response.success && response.data != null) {
        final userData = response.data;
        final user = _parseUserFromBackend(userData);
        _setLoading(false);
        return user;
      } else {
        _setError(response.message);
        _setLoading(false);
        return null;
      }
    } catch (e) {
      debugPrint('Get profile error: $e');
      _setError('Failed to load profile');
      _setLoading(false);
      return null;
    }
  }
  
  /// Update user profile
  Future<User?> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? jobTitle,
    String? bio,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Build request body - only include non-null values
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (company != null) body['company'] = company;
      if (jobTitle != null) body['jobTitle'] = jobTitle;
      if (bio != null) body['bio'] = bio;
      
      final response = await _apiService.put(
        ApiConfig.userMe,
        body: body,
      );
      
      debugPrint('Update profile response: $response');
      
      if (response.success && response.data != null) {
        final userData = response.data;
        final user = _parseUserFromBackend(userData);
        _setLoading(false);
        notifyListeners();
        return user;
      } else {
        _setError(response.message);
        _setLoading(false);
        return null;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      _setError('Failed to update profile');
      _setLoading(false);
      return null;
    }
  }
  
  /// Change user password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.put(
        ApiConfig.userPassword,
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      
      debugPrint('Change password response: $response');
      
      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      _setError('Failed to change password');
      _setLoading(false);
      return false;
    }
  }
  
  /// Delete user account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.delete(ApiConfig.userMe);
      
      debugPrint('Delete account response: $response');
      
      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Delete account error: $e');
      _setError('Failed to delete account');
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
  
  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
}
