import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

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
    
    // Debug: Log raw response
    print('================================================================================');
    print('🔍 API RESPONSE DEBUG [Status: $statusCode]');
    print('Response body length: ${response.body.length} characters');
    print('Response body isEmpty: ${response.body.isEmpty}');
    if (response.body.isNotEmpty && response.body.length <= 1000) {
      print('Full response body: ${response.body}');
    } else if (response.body.isNotEmpty) {
      print('Response body (first 1000 chars): ${response.body.substring(0, 1000)}');
    }
    
    // Try to parse JSON response (could be Map or List)
    dynamic jsonData;
    Map<String, dynamic>? jsonMap;
    try {
      if (response.body.isNotEmpty) {
        jsonData = jsonDecode(response.body);
        print('✅ JSON parsed successfully');
        print('Parsed data type: ${jsonData.runtimeType}');
        print('Is List: ${jsonData is List}');
        print('Is Map: ${jsonData is Map}');
        if (jsonData is List) {
          print('List length: ${jsonData.length}');
        }
        
        // If it's a Map, store it separately for extracting message/error
        if (jsonData is Map<String, dynamic>) {
          jsonMap = jsonData;
        }
      } else {
        print('⚠️ Response body is EMPTY!');
      }
    } catch (e) {
      // Response is not JSON
      print('❌ Failed to parse JSON: $e');
    }
    print('================================================================================');
    
    // Success (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(
        success: true,
        message: jsonMap?['message'] ?? 'Success',
        // If jsonData is a List, use it directly. If it's a Map, check for 'data' field
        data: jsonData is List 
            ? jsonData 
            : (jsonMap?['data'] ?? jsonData),
        statusCode: statusCode,
      );
    }
    
    // Error
    String errorMessage = 'Something went wrong';
    if (jsonMap != null) {
      // Check if error is an object with message field (backend format)
      if (jsonMap['error'] is Map) {
        errorMessage = jsonMap['error']['message'] ?? errorMessage;
      } else if (jsonMap['message'] is String) {
        errorMessage = jsonMap['message'];
      } else if (jsonMap['error'] is String) {
        errorMessage = jsonMap['error'];
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
