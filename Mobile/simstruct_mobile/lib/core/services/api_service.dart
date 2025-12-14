import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

/// Simple API Service for making HTTP requests
/// This handles GET, POST, PUT, DELETE with JWT token
class ApiService {
  // Secure storage for JWT token
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Key for storing token
  static const String _tokenKey = 'jwt_token';
  
  // ========== TOKEN MANAGEMENT ==========
  
  /// Save JWT token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  /// Get JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  /// Delete JWT token (for logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  /// Check if user has token (is logged in)
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // ========== HTTP HEADERS ==========
  
  /// Get headers with JWT token
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // ========== HTTP METHODS ==========
  
  /// GET request
  Future<ApiResponse> get(String url, {bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
  
  /// POST request
  Future<ApiResponse> post(String url, {Map<String, dynamic>? body, bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
  
  /// PUT request
  Future<ApiResponse> put(String url, {Map<String, dynamic>? body, bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
  
  /// DELETE request
  Future<ApiResponse> delete(String url, {bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
  
  // ========== RESPONSE HANDLING ==========
  
  /// Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Try to parse JSON response
    Map<String, dynamic>? jsonData;
    try {
      if (response.body.isNotEmpty) {
        jsonData = jsonDecode(response.body);
      }
    } catch (e) {
      // Response is not JSON
    }
    
    // Success (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(
        success: true,
        message: jsonData?['message'] ?? 'Success',
        data: jsonData?['data'] ?? jsonData,
        statusCode: statusCode,
      );
    }
    
    // Error
    String errorMessage = 'Something went wrong';
    if (jsonData != null) {
      // Check if error is an object with message field (backend format)
      if (jsonData['error'] is Map) {
        errorMessage = jsonData['error']['message'] ?? errorMessage;
      } else if (jsonData['message'] is String) {
        errorMessage = jsonData['message'];
      } else if (jsonData['error'] is String) {
        errorMessage = jsonData['error'];
      }
    }
    
    // Handle specific status codes
    if (statusCode == 401) {
      // Use backend message if available, otherwise default
      if (errorMessage == 'Something went wrong') {
        errorMessage = 'Invalid email or password';
      }
    } else if (statusCode == 403) {
      errorMessage = 'Access denied';
    } else if (statusCode == 404) {
      errorMessage = 'Not found';
    } else if (statusCode == 500) {
      errorMessage = 'Server error. Please try again later.';
    }
    
    return ApiResponse(
      success: false,
      message: errorMessage,
      data: jsonData,
      statusCode: statusCode,
    );
  }
}

/// Simple API Response class
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
  
  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
